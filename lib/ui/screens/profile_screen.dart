import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
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
  late final MemberCubit _cubit;

  @override
  void initState() {
    _cubit = MemberCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
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

  Widget _makeDescriptionFact(ListMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 5),
          _fieldLabel('About ${member.displayName}'),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              member.profileDescription != null
                  ? member.profileDescription!
                  : "This member hasn't created a description yet.",
              style: TextStyle(
                fontStyle: member.profileDescription != null
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
        ],
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
        _makeDescriptionFact(member),
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
    print(member.societies);
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
      body: BlocBuilder<MemberCubit, DetailState<Member>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.hasException) {
            return CustomScrollView(
              slivers: [
                _ProfileAppBar(pk: widget.pk),
                SliverFillRemaining(
                  child: ErrorCenter(state.message!),
                ),
              ],
            );
          } else if (state.isLoading && widget.member == null) {
            return CustomScrollView(
              slivers: [
                _ProfileAppBar(pk: widget.pk),
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                _ProfileAppBar(
                  pk: widget.pk,
                  member: (state.result ?? widget.member)!,
                ),
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

class _ProfileAppBar extends SliverAppBar {
  final ListMember? member;
  final int pk;

  _ProfileAppBar({required this.pk, this.member})
      : super(
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
                      Hero(
                        tag: 'member_$pk',
                        child: member != null
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/img/default-avatar.jpg',
                                image: member.photo.full,
                                fit: BoxFit.cover,
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
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

  static void _showAvatarView(BuildContext context, ListMember member) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Scaffold(
          body: Stack(
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
              CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        );
      },
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
