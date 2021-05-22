import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/blocs/member_cubit.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/widgets/error_center.dart';
import 'package:url_launcher/link.dart';

/// Screen that loads and shows a the profile of the member with `pk`.
class ProfileScreen extends StatefulWidget {
  final int pk;
  final ListMember? member;

  ProfileScreen({required this.pk, this.member}) : super(key: ValueKey(pk));

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final MemberCubit _memberCubit;

  @override
  void initState() {
    _memberCubit = MemberCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  void _showAvatarView(BuildContext context, ListMember member) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
        final isMe = fullMemberCubit.state.result?.pk == member.pk;
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(member.photo.full),
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'member_${member.pk}',
                ),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 1.2,
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CloseButton(
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    if (isMe)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_a_photo_outlined),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.getImage(
                                source: ImageSource.camera,
                                preferredCameraDevice: CameraDevice.front,
                              );
                              final imagePath = pickedFile?.path;
                              if (imagePath == null) return;
                              final croppedFile = await ImageCropper.cropImage(
                                  sourcePath: imagePath,
                                  iosUiSettings: IOSUiSettings(title: 'Crop'),
                                  compressFormat: ImageCompressFormat.jpg);
                              if (croppedFile == null) return;
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              // Not ThaliaRouterDelegate since this is a dialog.
                              Navigator.of(context).pop();
                              scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                  'Uploading your new profile picture',
                                ),
                              ));
                              try {
                                await fullMemberCubit.updateAvatar(croppedFile);
                                // The member that is displayed is currently
                                // taken from the MemberCubit. If needed, we
                                // could make the ProfileScreen listen to the
                                // FullMemberCubit instead in case the member is
                                // the current user. That would be nicer if we
                                // want to allow the user to update multiple
                                // fields. As long as that isn't the case, we
                                // also need to reload the MemberCubit below.
                                await _memberCubit.load(member.pk);
                                scaffoldMessenger.hideCurrentSnackBar();
                              } on ApiException {
                                scaffoldMessenger.hideCurrentSnackBar();
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    'Uploading your avatar failed.',
                                  ),
                                ));
                              }
                            },
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          IconButton(
                            icon: Icon(Icons.add_photo_alternate_outlined),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.getImage(
                                source: ImageSource.gallery,
                              );
                              final imagePath = pickedFile?.path;
                              if (imagePath == null) return;
                              final croppedFile = await ImageCropper.cropImage(
                                sourcePath: imagePath,
                                iosUiSettings: IOSUiSettings(title: 'Crop'),
                              );
                              if (croppedFile == null) return;
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              // Not ThaliaRouterDelegate since this is a dialog.
                              Navigator.of(context).pop();
                              // TODO: Make fancy snackbars everywhere. Here we
                              //  add a progressindicator. Many other snackbars
                              //  could at least use some styling, and possibly
                              //  icons.
                              scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                  'Uploading your new profile picture',
                                ),
                              ));
                              try {
                                await fullMemberCubit.updateAvatar(croppedFile);
                                // The member that is displayed is currently
                                // taken from the MemberCubit. If needed, we
                                // could make the ProfileScreen listen to the
                                // FullMemberCubit instead in case the member is
                                // the current user. That would be nicer if we
                                // want to allow the user to update multiple
                                // fields. As long as that isn't the case, we
                                // also need to reload the MemberCubit below.
                                await _memberCubit.load(member.pk);
                                scaffoldMessenger.hideCurrentSnackBar();
                              } on ApiException {
                                scaffoldMessenger.hideCurrentSnackBar();
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    'Uploading your avatar failed.',
                                  ),
                                ));
                              }
                            },
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _makeAppBar([ListMember? member]) {
    return SliverAppBar(
      brightness: Brightness.dark,
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(member?.displayName ?? 'Profile'),
        background: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: member != null
                  ? () => _showAvatarView(context, member)
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Color(0xFFC5C5C5)),
                  ),
                  Hero(
                    tag: 'member_${widget.pk}',
                    child: member != null
                        ? FadeInImage.assetNetwork(
                            placeholder: 'assets/img/default-avatar.jpg',
                            image: member.photo.small,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                          )
                        : Image.asset(
                            'assets/img/default-avatar.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                  _BlackGradient()
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fieldLabel(String title) {
    return Text(title, style: Theme.of(context).textTheme.subtitle2);
  }

  Divider _factDivider() {
    return const Divider(
      height: 3,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _makeHonoraryFact() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'Honorary Member',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  Widget _makeStudiesFact(ListMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _fieldLabel('Study programme')),
              Flexible(child: _fieldLabel('Cohort')),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    member.programme == Programme.computingscience
                        ? 'Computing Science'
                        : 'Information Science',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    member.startingYear!.toString(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _makeBirthdayFact(ListMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 5),
          _fieldLabel('Birthday'),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              DateFormat('d MMMM y').format(member.birthday!),
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeWebsiteFact(ListMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 5),
          _fieldLabel('Website'),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Link(
              uri: member.website!,
              target: LinkTarget.blank,
              builder: (context, followLink) => GestureDetector(
                onTap: followLink,
                child: Text(
                  member.website!.toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverList _makeFactsSliver(ListMember member) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        if (member.membershipType == MembershipType.honorary) ...[
          _makeHonoraryFact(),
          _factDivider(),
        ],
        _DescriptionFact(member: member, cubit: _memberCubit),
        _factDivider(),
        if (member.startingYear != null && member.programme != null) ...[
          _makeStudiesFact(member),
          _factDivider(),
        ],
        if (member.birthday != null) ...[
          _makeBirthdayFact(member),
          _factDivider(),
        ],
        if (member.website != null) ...[
          _makeWebsiteFact(member),
          _factDivider(),
        ],
      ]),
    );
  }

  Widget _makeAchievementTile(Achievement achievement) {
    Widget? periodCol;
    if (achievement.periods != null) {
      periodCol = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: achievement.periods!.map((Period period) {
          final formatter = DateFormat('d MMMM y');
          final since = formatter.format(period.since);
          final until = (period.until != null)
              ? formatter.format(period.since)
              : 'Present';
          final dates = '$since - $until';
          var leading = '';
          if (period.chair) {
            leading = 'Chair: ';
          } else if (period.role != null) {
            leading = '${period.role}: ';
          }
          return Text(leading + dates);
        }).toList(),
      );
    }

    return ListTile(
      title: Text(
        achievement.name,
        style: const TextStyle(fontSize: 18),
      ),
      subtitle: periodCol,
      contentPadding: EdgeInsets.zero,
    );
  }

  SliverPadding _makeAchievementsSliver(Member member) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: 5),
          _fieldLabel('Achievements for Thalia'),
          ...ListTile.divideTiles(
            context: context,
            tiles: member.achievements.map(_makeAchievementTile),
          )
        ]),
      ),
    );
  }

  SliverPadding _makeSocietiesSliver(Member member) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(height: 5),
          _fieldLabel('Societies'),
          ...ListTile.divideTiles(
            context: context,
            tiles: member.societies.map(_makeAchievementTile),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MemberCubit, MemberState>(
        bloc: _memberCubit,
        builder: (context, state) {
          if (state.hasException) {
            return CustomScrollView(
              slivers: [
                _makeAppBar(),
                SliverFillRemaining(
                  child: ErrorCenter(state.message!),
                ),
              ],
            );
          } else if (state.isLoading && widget.member == null) {
            return CustomScrollView(
              slivers: [
                _makeAppBar(),
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                _makeAppBar((state.result ?? widget.member)!),
                _makeFactsSliver((state.result ?? widget.member)!),
                if (!state.isLoading) ...[
                  if (state.result!.achievements.isNotEmpty)
                    _makeAchievementsSliver(state.result!),
                  if (state.result!.societies.isNotEmpty)
                    _makeSocietiesSliver(state.result!),
                ] else
                  SliverPadding(
                    padding: EdgeInsets.all(10),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _BlackGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.3),
          ],
          stops: [0.5, 1.0],
        ),
      ),
    );
  }
}

class _DescriptionFact extends StatefulWidget {
  final ListMember member;
  final MemberCubit cubit;
  const _DescriptionFact({
    Key? key,
    required this.member,
    required this.cubit,
  }) : super(key: key);

  @override
  __DescriptionFactState createState() => __DescriptionFactState();
}

class __DescriptionFactState extends State<_DescriptionFact>
    with TickerProviderStateMixin {
  bool isEditting = false;
  late final TextEditingController _controller;
  late final FullMemberCubit _fullMemberCubit;

  @override
  void initState() {
    _fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    _controller = TextEditingController.fromValue(
      TextEditingValue(text: widget.member.profileDescription ?? ''),
    );
    super.initState();
  }

  Widget _fieldLabel(String title) {
    return Text(title, style: Theme.of(context).textTheme.subtitle2);
  }

  @override
  Widget build(BuildContext context) {
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    final isMe = fullMemberCubit.state.result?.pk == widget.member.pk;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 5),
          _fieldLabel('About ${widget.member.displayName}'),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.all(5),
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: isEditting
                    ? Row(
                        key: ValueKey(true),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 5,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () async {
                              try {
                                await _fullMemberCubit.updateDescription(
                                  _controller.text,
                                );
                                await widget.cubit.load(widget.member.pk);
                              } on ApiException {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                      'Uploading your avatar failed.',
                                    ),
                                  ),
                                );
                              }
                              setState(() => isEditting = false);
                            },
                          ),
                        ],
                      )
                    : Row(
                        key: ValueKey(false),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              (widget.member.profileDescription?.isEmpty ??
                                      true)
                                  ? "This member hasn't created a description yet."
                                  : widget.member.profileDescription!,
                              style: TextStyle(
                                fontStyle: (widget.member.profileDescription
                                            ?.isEmpty ??
                                        true)
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                          if (isMe)
                            IconButton(
                              tooltip: 'Edit your description',
                              icon: Icon(Icons.edit_outlined),
                              onPressed: () {
                                setState(() => isEditting = true);
                              },
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
