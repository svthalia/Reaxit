import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen that loads and shows a the profile of the member with `pk`.
class ProfileScreen extends StatefulWidget {
  final int pk;
  final ListMember? member;

  ProfileScreen({required this.pk, this.member}) : super(key: ValueKey(pk));

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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
      useSafeArea: false,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) {
        return AvatarViewDialog(member: member, memberCubit: _memberCubit);
      },
    );
  }

  SliverAppBar _makeAppBar([ListMember? member]) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    final isMe = fullMemberCubit.state.result?.pk == member?.pk;
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
            return Stack(
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
                const _BlackGradient(),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: member != null
                          ? () => _showAvatarView(context, member)
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: isMe
          ? [
              IconButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                color: Theme.of(context).primaryIconTheme.color,
                icon: const Icon(Icons.photo_camera_outlined),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    preferredCameraDevice: CameraDevice.front,
                  );
                  final imagePath = pickedFile?.path;
                  if (imagePath == null) return;
                  final croppedFile = await ImageCropper().cropImage(
                      sourcePath: imagePath,
                      uiSettings: [IOSUiSettings(title: 'Crop')],
                      compressFormat: ImageCompressFormat.jpg);
                  if (croppedFile == null) return;

                  messenger.showSnackBar(const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Uploading your new profile picture...',
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
                    await _memberCubit.load(member!.pk);
                    messenger.hideCurrentSnackBar();
                  } on ApiException {
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Uploading your avatar failed.',
                      ),
                    ));
                  }
                },
              ),
              IconButton(
                padding: const EdgeInsets.only(
                  top: 16,
                  right: 16,
                  bottom: 16,
                  left: 12,
                ),
                color: Theme.of(context).primaryIconTheme.color,
                icon: const Icon(Icons.photo_outlined),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  final imagePath = pickedFile?.path;
                  if (imagePath == null) return;
                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: imagePath,
                    uiSettings: [IOSUiSettings(title: 'Crop')],
                  );
                  if (croppedFile == null) return;
                  messenger.showSnackBar(const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Uploading your new profile picture...',
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
                    await _memberCubit.load(member!.pk);
                    messenger.hideCurrentSnackBar();
                  } on ApiException {
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Uploading your avatar failed.',
                      ),
                    ));
                  }
                },
              ),
            ]
          : null,
    );
  }

  Widget _fieldLabel(String title) {
    return Text(title, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _makeHonoraryFact() {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'HONORARY MEMBER',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _makeStudiesFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('STUDY PROGRAMME'),
        const SizedBox(height: 4),
        Text(
          member.programme == Programme.computingscience
              ? 'Computing Science'
              : 'Information Science',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _makeCohortFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('COHORT'),
        const SizedBox(height: 4),
        Text(
          member.startingYear!.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _makeBirthdayFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('BIRTHDAY'),
        const SizedBox(height: 4),
        Text(
          dateFormatter.format(member.birthday!),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _makeWebsiteFact(ListMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('WEBSITE'),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: member.website != null
              ? () async {
                  await launchUrl(
                    member.website!,
                    mode: LaunchMode.externalApplication,
                  );
                }
              : null,
          child: Text(
            member.website!.toString(),
            style: Theme.of(context).textTheme.titleSmall,
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
          const Divider(height: 24),
          if (member.programme != null) ...[
            _makeStudiesFact(member),
          ],
          if (member.startingYear != null) ...[
            const SizedBox(height: 12),
            _makeCohortFact(member),
          ],
          if (member.birthday != null) ...[
            const SizedBox(height: 12),
            _makeBirthdayFact(member),
          ],
          if (member.website != null) ...[
            const SizedBox(height: 12),
            _makeWebsiteFact(member),
          ],
          const Divider(height: 24),
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
              ? dateFormatter.format(period.until!)
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
        style: Theme.of(context).textTheme.titleMedium,
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
          _fieldLabel('ACHIEVEMENTS FOR THALIA'),
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
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  SliverToBoxAdapter _makeSocietiesSliver(Member member) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('SOCIETIES'),
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
          ),
          const SizedBox(height: 8),
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
          if (state is ErrorState) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                _makeAppBar(),
                SliverFillRemaining(
                  child: ErrorCenter(state.message!),
                ),
              ],
            );
          } else if (state is LoadingState && widget.member == null) {
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
                if (state is! LoadingState) ...[
                  if (state.result!.achievements.isNotEmpty)
                    _makeAchievementsSliver(state.result!),
                  if (state.result!.societies.isNotEmpty)
                    _makeSocietiesSliver(state.result!),
                ] else ...[
                  const SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32))
              ],
            );
          }
        },
      ),
    );
  }
}

class AvatarViewDialog extends StatefulWidget {
  const AvatarViewDialog({
    Key? key,
    required this.member,
    required this.memberCubit,
  }) : super(key: key);

  final ListMember member;
  final MemberCubit memberCubit;

  @override
  State<AvatarViewDialog> createState() => _AvatarViewDialogState();
}

class _AvatarViewDialogState extends State<AvatarViewDialog> {
  @override
  Widget build(BuildContext context) {
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    final isMe = fullMemberCubit.state.result?.pk == widget.member.pk;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: CloseButton(
          color: Theme.of(context).primaryIconTheme.color,
        ),
        actions: isMe
            ? [
                IconButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  color: Theme.of(context).primaryIconTheme.color,
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: _takePicture,
                ),
                IconButton(
                  padding: const EdgeInsets.only(
                    top: 16,
                    right: 16,
                    bottom: 16,
                    left: 12,
                  ),
                  color: Theme.of(context).primaryIconTheme.color,
                  icon: const Icon(Icons.photo_outlined),
                  onPressed: _choosePicture,
                ),
              ]
            : null,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.member.photo.full),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 1.2,
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    final messenger = ScaffoldMessenger.of(context);
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    final imagePath = pickedFile?.path;
    if (imagePath == null) return;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [IOSUiSettings(title: 'Crop')],
      compressFormat: ImageCompressFormat.jpg,
    );
    if (croppedFile == null) return;

    if (mounted) Navigator.of(context).pop();

    messenger.showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Uploading your new profile picture...',
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
      await widget.memberCubit.load(widget.member.pk);
      messenger.hideCurrentSnackBar();
    } on ApiException {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Uploading your avatar failed.',
        ),
      ));
    }
  }

  Future<void> _choosePicture() async {
    final messenger = ScaffoldMessenger.of(context);
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    final imagePath = pickedFile?.path;
    if (imagePath == null) return;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [IOSUiSettings(title: 'Crop')],
    );
    if (croppedFile == null) return;

    if (mounted) Navigator.of(context).pop();

    messenger.showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Uploading your new profile picture...',
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
      await widget.memberCubit.load(widget.member.pk);
      messenger.hideCurrentSnackBar();
    } on ApiException {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Uploading your avatar failed.',
        ),
      ));
    }
  }
}

class _BlackGradient extends StatelessWidget {
  static const _black00 = Color(0x00000000);
  static const _black40 = Color(0x66000000);

  const _BlackGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [_black00, _black40],
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
    return Text(title, style: Theme.of(context).textTheme.bodySmall);
  }

  @override
  Widget build(BuildContext context) {
    final fullMemberCubit = BlocProvider.of<FullMemberCubit>(context);
    final isMe = fullMemberCubit.state.result?.pk == widget.member.pk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('ABOUT ${widget.member.displayName.toUpperCase()}'),
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        tooltip: 'Edit your avatar',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _fullMemberCubit.updateDescription(
                              _controller.text,
                            );
                            await widget.cubit.load(widget.member.pk);
                          } on ApiException {
                            messenger.showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  'Updating your description failed.',
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
                          style: (widget.member.profileDescription?.isEmpty ??
                                  true)
                              ? Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontStyle: FontStyle.normal,
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
