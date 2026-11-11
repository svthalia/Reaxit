import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/models/photo.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/gallery.dart';
import 'package:reaxit/ui/widgets/photo_tile.dart';

typedef PhotosState = DetailState<InnerListState<AlbumPhoto>>;

class FaceDetectionScreen extends StatelessWidget {

  void _openGallery<C extends PhotosCubit>(BuildContext context, int index) {
    final cubit = context.read<C>(); // BlocProvider.of<PhotosCubit>(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<C, PhotosState>(
            buildWhen: (previous, current) => switch (current) {
              LoadingState _ || LoadingResultState _ => false,
              _ => true,
            },
            builder: (context, state) {
              late final List<AlbumPhoto> results;
              late final int count;
              switch (state) {
                case ResultState(
                  result: InnerListState(results: final res, count: final cnt),
                ):
                  results = res;
                  count = cnt;
                case _:
                  results = [];
                  count = 0;
              }

              return Gallery<C>(
                photos: results,
                initialPage: index,
                photoAmount: count,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('FACE DETECTION'),
        collapsingActions: [
          IconAppbarAction(
            'FACE DETECTION',
            Icons.info,
            () => showFaceDectionInfoDialog(context),
          ),
        ],
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ReferencePhotosCubit(
                  RepositoryProvider.of<ApiRepository>(context),
                )..load(),
          ),
          BlocProvider(
            create: (context) =>
                FaceDetectionPhotosCubit(
                  RepositoryProvider.of<ApiRepository>(context),
                )..load(),
          ),
        ],
        child: Builder(
          builder: (context) {
            return CustomScrollView(
            slivers: [

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'REFERENCE PHOTOS',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      Divider(height: 8),
                    ],
                  ),
                ),
              ),

              BlocBuilder<ReferencePhotosCubit, PhotosState>(
                builder: (context, state) {
                  final photos = switch (state) {
                    ResultState(
                      result: InnerListState(
                        results: final List<AlbumPhoto> results,
                      ),
                    ) => results,
                    _ => <AlbumPhoto>[],
                  };

                  if (photos.isEmpty) {
                    return SliverPadding(padding: EdgeInsets.all(8), 
                    sliver: SliverToBoxAdapter(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'No reference photos available.',
                                style: textTheme.titleLarge,
                              ),
                            ),
                            Text(
                              "Upload a reference photo of yourself and we'll look for other photos you appear on. Note that for the best result, this photo should contain only your face. A reference photo with multiple faces on it will be rejected. It may take some time until we have processed your reference photos. \n"
                            ),
                          ]
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: 
                      SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PhotoTile(
                            photo: photos[index],
                            openGallery: () =>
                                _openGalleryReferencePhoto(
                              context,
                              index,
                            ),
                          ),
                          childCount: photos.length,
                        ),
                      ),
                    );
                },
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Tap on a reference photo to remove it.',
                        style: textTheme.bodyMedium),), 
                    ElevatedButton(
                      onPressed: () {
                        final referenceCubit = context.read<ReferencePhotosCubit>();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Add reference photo'),
                              content: const Text(
                                'How do you want to add a reference photo?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Take a new photo'),
                                  onPressed: () {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    uploadPhotoMakePhoto(
                                      context,
                                      referenceCubit,
                                      messenger,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Upload from gallery'),
                                  onPressed: () {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    uploadPhotoGallery(
                                      context,
                                      referenceCubit,
                                      messenger,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Upload New Reference Photo '),
                          Icon(Icons.file_upload_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(height: 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "PHOTOS YOU'RE ON",
                        style: textTheme.titleLarge,
                      ),
                    ),
                    Divider(height: 0),
                  ],
                ),
              ),
            ),

              BlocBuilder<FaceDetectionPhotosCubit, PhotosState>(
                builder: (context, state) {
                  final photos = switch (state) {
                    ResultState(
                      result: InnerListState(
                        results: final List<AlbumPhoto> results,
                      ),
                    ) => results,
                    _ => <AlbumPhoto>[],
                  };

                  return SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: 
                      SliverGrid(
                        gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PhotoTile(
                            photo: photos[index],
                            openGallery: () =>
                                _openGallery<FaceDetectionPhotosCubit>(
                              context,
                              index,
                            ),
                          ),
                          childCount: photos.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      ),
    );
  }

void _openGalleryReferencePhoto(BuildContext context, int index) {
  final cubit = context.read<ReferencePhotosCubit>();

  final state = cubit.state;

  final photos = switch (state) {
    ResultState(
      result: InnerListState(
        results: final List<AlbumPhoto> results,
      ),
    ) => results,
    _ => <AlbumPhoto>[],
  };

  if (index >= photos.length) return;

  final photoPk = photos[index].pk;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Remove reference photo'),
        content: const Text(
          'We will store your reference face for 180 more days after you remove it. '
          'This allows us to monitor if you actually searched for photos of others. '
          'Are you sure you want to delete this reference photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await cubit.deleteReferencePhoto(photoPk);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
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
      content: Text('Uploading a new referene picture...'),
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
        content: Text('Uploading your reference photo.'),
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

void showFaceDectionInfoDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('How does this work?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Upload a reference photo of yourself and we'll look for other photos you appear on. Note that for the best result, this photo should contain only your face. A reference photo with multiple faces on it will be rejected. It may take some time until we have processed your reference photos.",
            ),
            const Text(
              '\u2022 Face recognition is intended to be used for your own faces only.',
            ),
            const Text(
              '\u2022 You can have a maximum of 5 reference faces uploaded.        ',
            ),
            const Text(
              "\u2022 You can only search for faces for the period that you've been a member.",
            ),
            const Text(
              '\u2022 After you have uploaded a reference face, you can not just delete it. We will store your reference faces for 180 more days after you delete them. This allows us to monitor if you actually searched for photos of others.',
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}