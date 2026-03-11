import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/photo_grid_sliver.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen();

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late ScrollController _controller;
  late final FaceDetectionPhotosCubit _cubit;
  late final ReferencePhotosCubit _referenceCubit;

  @override
  void initState() {
    _controller = ScrollController()..addListener(_scrollListener);
    _cubit = FaceDetectionPhotosCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    _referenceCubit = ReferencePhotosCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load();
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.more();
      _referenceCubit.more();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    _referenceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PhotosCubit>.value(value: _cubit),
        BlocProvider.value(value: _referenceCubit),
      ],
      child: Scaffold(
        appBar: ThaliaAppBar(title: const Text("PHOTOS YOU'RE ON")),
        body: RefreshIndicator(
          onRefresh: () async {
            await _cubit.load();
            await _referenceCubit.load();
          },
          child: BlocBuilder<PhotosCubit, FaceDetectionPhotosState>(
            builder: (context, state) {
              return BlocBuilder<ReferencePhotosCubit, ReferencePhotosState>(
                builder: (referenceContext, referenceState) {
                  if (state.hasException) {
                    return ErrorScrollView(state.message!);
                  }

                  return FaceDetectionGridScrollView(
                    controller: _controller,
                    listState: state,
                    referenceState: referenceState,
                    referenceCubit: _referenceCubit,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class FaceDetectionGridScrollView extends StatelessWidget {
  final ScrollController controller;
  final ListState<AlbumPhoto> listState;
  final ListState<AlbumPhoto> referenceState;
  final ReferencePhotosCubit referenceCubit;

  const FaceDetectionGridScrollView({
    required this.controller,
    required this.listState,
    required this.referenceState,
    required this.referenceCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (referenceState.results.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No reference photos found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Reference photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PhotoGridSliver(
            listState: referenceState,
            customOpenGallery: _openGallery,
          ),
          if (referenceState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(child: CircularProgressIndicator()),
                ]),
              ),
            ),
          SliverToBoxAdapter(
            child: ElevatedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                uploadPhotoGallery(context, referenceCubit, messenger);
              },
              child: Text('Add reference photo from gallery'),
            ),
          ),
          SliverToBoxAdapter(
            child: ElevatedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                uploadPhotoMakePhoto(context, referenceCubit, messenger);
              },
              child: Text('Add reference photo from camera'),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Photos you\'re on',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PhotoGridSliver(listState: listState),
          if (listState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(child: CircularProgressIndicator()),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> uploadPhoto(
  XFile? pickedFile,
  ReferencePhotosCubit cubit,
  ScaffoldMessengerState messenger,
) async {
  final imagePath = pickedFile?.path;
  if (imagePath == null) return;
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imagePath,
    uiSettings: [IOSUiSettings(title: 'Crop')],
    compressFormat: ImageCompressFormat.jpg,
  );

  messenger.showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Uploading your new profile picture...'),
    ),
  );

  try {
    await cubit.updateReferencePhoto(croppedFile!);
    messenger.hideCurrentSnackBar();
  } on ApiException {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Uploading your avatar failed.'),
      ),
    );
  }
}

Future<void> uploadPhotoMakePhoto(
  BuildContext context,
  ReferencePhotosCubit cubit,
  ScaffoldMessengerState messenger,
) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
  );
  await uploadPhoto(pickedFile, cubit, messenger);
}

Future<void> uploadPhotoGallery(
  BuildContext context,
  ReferencePhotosCubit cubit,
  ScaffoldMessengerState messenger,
) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  await uploadPhoto(pickedFile, cubit, messenger);
}

void _openGallery(BuildContext context, int index) {
  final cubit = context.read<ReferencePhotosCubit>();
  final photoPk = cubit.state.results[index].pk;

  // When this function is called, the reference photo needs to be deleted, so we need to make an api request
  // to delete the reference photo at index index.

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Remove reference photo'),
        content: const Text(
          'We will store your reference face for 180 more days after you remove it. This allows us to monitor if you actually searched for photos of others. Are you sure you want to delete this reference photo?',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Delete'),
            onPressed: () {
              cubit.deleteReferencePhoto(photoPk);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
