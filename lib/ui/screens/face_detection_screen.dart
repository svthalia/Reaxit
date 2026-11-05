import 'package:material_ui/material_ui.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/photo_tiles.dart';

class FaceDetectionScreen extends StatelessWidget {
  const FaceDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('FACE DETECTION'),
      ),
      body: Column (
        children: [
          Expanded(
            flex: 1,
            child: PhotoTiles<ReferencePhotosCubit>(
              createCubit: ReferencePhotosCubit.new,
            )
          ),
          Expanded(
            flex: 4,
            child: PhotoTiles<FaceDetectionPhotosCubit>(
              createCubit: FaceDetectionPhotosCubit.new,
          ),),
        ],
      ),
    );
  }
}