import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reaxit/api_repository.dart';
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
  static final dateFormatter = DateFormat('d MMMM y');
  late final MemberCubit _memberCubit;

  // Constants to determine padding for app bar title on android.
  static const basePadding = 16.0;
  static const collapsedPadding = 56.0;
  static const expandedHeight = 200.0;

  /// ValueNotifier for the left-side padding of the app bar title on android.
  final ValueNotifier<double> _appBarTitlePaddingNotifier = ValueNotifier(16.0);
  final _scrollController = ScrollController();

  /// Calculate the left-side padding of the app bar title on android.
  double get _horizontalTitlePadding {
    if (_scrollController.hasClients) {
      return min(
        basePadding + collapsedPadding,
        basePadding +
            (collapsedPadding * _scrollController.offset) /
                (expandedHeight - kToolbarHeight),
      );
    }
    return basePadding;
  }

  @override
  void initState() {
    _memberCubit = MemberCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);

    _scrollController.addListener(() {
      _appBarTitlePaddingNotifier.value = _horizontalTitlePadding;
    });

    super.initState();
  }

  @override
  void dispose() {
    _memberCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAvatarView(BuildContext context, ListMember member) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
        final isMe = fullMemberCubit.state.result?.pk == member.pk;
        return Dismissible(
          key: UniqueKey(),
          behavior: HitTestBehavior.translucent,
          direction: DismissDirection.down,
          onDismissed: (_) => Navigator.of(context).pop(),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                PhotoView(
                  imageProvider: NetworkImage(member.photo.full),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 1.2,
                  loadingBuilder: (_, __) => const CircularProgressIndicator(),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
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
                              icon: const Icon(Icons.add_a_photo_outlined),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.camera,
                                  preferredCameraDevice: CameraDevice.front,
                                );
                                final imagePath = pickedFile?.path;
                                if (imagePath == null) return;
                                final croppedFile =
                                    await ImageCropper.cropImage(
                                        sourcePath: imagePath,
                                        iosUiSettings: const IOSUiSettings(
                                          title: 'Crop',
                                        ),
                                        compressFormat:
                                            ImageCompressFormat.jpg);
                                if (croppedFile == null) return;
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                // Not ThaliaRouterDelegate since this is a dialog.
                                Navigator.of(context).pop();
                                scaffoldMessenger.showSnackBar(const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Uploading your new profile picture...',
                                  ),
                                ));
                                try {
                                  await fullMemberCubit
                                      .updateAvatar(croppedFile);
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
                                  scaffoldMessenger.showSnackBar(const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Uploading your avatar failed.',
                                    ),
                                  ));
                                }
                              },
                              color: Theme.of(context).primaryIconTheme.color,
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.add_photo_alternate_outlined),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                final imagePath = pickedFile?.path;
                                if (imagePath == null) return;
                                final croppedFile =
                                    await ImageCropper.cropImage(
                                  sourcePath: imagePath,
                                  iosUiSettings: const IOSUiSettings(
                                    title: 'Crop',
                                  ),
                                );
                                if (croppedFile == null) return;
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                // Not ThaliaRouterDelegate since this is a dialog.
                                Navigator.of(context).pop();
                                scaffoldMessenger.showSnackBar(const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Uploading your new profile picture...',
                                  ),
                                ));
                                try {
                                  await fullMemberCubit
                                      .updateAvatar(croppedFile);
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
                                  scaffoldMessenger.showSnackBar(const SnackBar(
                                    behavior: SnackBarBehavior.floating,
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
          ),
        );
      },
    );
  }

  SliverAppBar _makeAppBar([ListMember? member]) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: !isAndroid,
        title: isAndroid
            // Rebuilds whenever the listenable is changed
            // by the scroll controller listener.
            ? ValueListenableBuilder<double>(
                valueListenable: _appBarTitlePaddingNotifier,
                builder: (context, value, child) {
                  return Padding(
                    padding: EdgeInsets.only(left: value),
                    child: Text(
                      member?.displayName ?? 'PROFILE',
                      textAlign: TextAlign.left,
                    ),
                  );
                },
              )
            // Just centered text on iOS.
            : Text(
                member?.displayName ?? 'PROFILE',
                textAlign: TextAlign.center,
              ),
        // Bottom padding of only 14 instead of 16 because by default (16) there
        // is a misalignment of the baseline compared to the standard AppBar.
        titlePadding: const EdgeInsets.only(bottom: 14),
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
                    decoration: const BoxDecoration(color: Color(0xFFC5C5C5)),
                  ),
                  member != null
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/img/default-avatar.jpg',
                          image: member.photo.medium,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                        )
                      : Image.asset(
                          'assets/img/default-avatar.jpg',
                          fit: BoxFit.cover,
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
    return Text(title, style: Theme.of(context).textTheme.caption);
  }

  Widget _makeHonoraryFact() {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'HONORARY MEMBER',
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  Widget _makeStudiesFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Study programme'),
        const SizedBox(height: 4),
        Text(
          member.programme == Programme.computingscience
              ? 'Computing Science'
              : 'Information Science',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  Widget _makeCohortFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Cohort'),
        const SizedBox(height: 4),
        Text(
          member.startingYear!.toString(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  Widget _makeBirthdayFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Birthday'),
        const SizedBox(height: 4),
        Text(
          dateFormatter.format(member.birthday!),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ],
    );
  }

  Widget _makeWebsiteFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Website'),
        const SizedBox(height: 4),
        Link(
          uri: member.website!,
          target: LinkTarget.blank,
          builder: (context, followLink) => GestureDetector(
            onTap: followLink,
            child: Text(
              member.website!.toString(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _makeFactsSliver(ListMember member) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(children: [
          if (member.membershipType == MembershipType.honorary) ...[
            _makeHonoraryFact(),
            const Divider(),
          ],
          _DescriptionFact(member: member, cubit: _memberCubit),
          const Divider(),
          if (member.programme != null) ...[
            _makeStudiesFact(member),
            const Divider(),
          ],
          if (member.startingYear != null) ...[
            _makeCohortFact(member),
            const Divider(),
          ],
          if (member.birthday != null) ...[
            _makeBirthdayFact(member),
            const Divider(),
          ],
          if (member.website != null) ...[
            _makeWebsiteFact(member),
            const Divider(),
          ],
        ]),
      ),
    );
  }

  Widget _makeAchievementTile(Achievement achievement) {
    Widget? periodColumn;
    if (achievement.periods != null) {
      periodColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: achievement.periods!.map((Period period) {
          final since = dateFormatter.format(period.since);
          final until = (period.until != null)
              ? dateFormatter.format(period.since)
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
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subtitle: periodColumn,
      dense: true,
    );
  }

  SliverToBoxAdapter _makeAchievementsSliver(Member member) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('Achievements for Thalia'),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ...ListTile.divideTiles(
                  context: context,
                  tiles: member.achievements.map(_makeAchievementTile),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  SliverToBoxAdapter _makeSocietiesSliver(Member member) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('Societies'),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ...ListTile.divideTiles(
                  context: context,
                  tiles: member.societies.map(_makeAchievementTile),
                )
              ],
            ),
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
              controller: _scrollController,
              slivers: [
                _makeAppBar(),
                SliverFillRemaining(
                  child: ErrorCenter(state.message!),
                ),
              ],
            );
          } else if (state.isLoading && widget.member == null) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _makeAppBar(),
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return CustomScrollView(
              key: const PageStorageKey('profile'),
              controller: _scrollController,
              slivers: [
                _makeAppBar((state.result ?? widget.member)!),
                _makeFactsSliver((state.result ?? widget.member)!),
                if (!state.isLoading) ...[
                  if (state.result!.achievements.isNotEmpty)
                    _makeAchievementsSliver(state.result!),
                  if (state.result!.societies.isNotEmpty)
                    _makeSocietiesSliver(state.result!),
                ] else
                  const SliverPadding(
                    padding: EdgeInsets.all(8),
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
          stops: const [0.5, 1.0],
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

class __DescriptionFactState extends State<_DescriptionFact> {
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

  @override
  void dispose() {
    _fullMemberCubit.close();
    _controller.dispose();
    super.dispose();
  }

  Widget _fieldLabel(String title) {
    return Text(title, style: Theme.of(context).textTheme.caption);
  }

  @override
  Widget build(BuildContext context) {
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    final isMe = fullMemberCubit.state.result?.pk == widget.member.pk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('About ${widget.member.displayName}'),
        const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isEditting
                ? Row(
                    key: const ValueKey(true),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        tooltip: 'Edit your description',
                        onPressed: () async {
                          try {
                            await _fullMemberCubit.updateDescription(
                              _controller.text,
                            );
                            await widget.cubit.load(widget.member.pk);
                          } on ApiException {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
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
                    key: const ValueKey(false),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          (widget.member.profileDescription?.isEmpty ?? true)
                              ? "This member hasn't created a description yet."
                              : widget.member.profileDescription!,
                          style:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
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
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            setState(() => isEditting = true);
                          },
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// TODO: Add photo index/total indicator to gallery.
