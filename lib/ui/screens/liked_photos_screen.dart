import 'package:material_ui/material_ui.dart';
import 'package:reaxit/blocs/photos_cubit.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/photo_tiles.dart';

class LikedPhotosScreen extends StatelessWidget {
  const LikedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('LIKED PHOTOS'),
      ),
      body: PhotoTiles<LikedPhotosCubit>(
        createCubit: LikedPhotosCubit.new,
      ),
    );
  }
}