import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/member.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/providers/members_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberDetail extends StatefulWidget {
  final int pk;
  final ListMember listMember;
  MemberDetail(this.pk, [this.listMember]);

  @override
  _MemberDetailState createState() => _MemberDetailState();
}

class _MemberDetailState extends State<MemberDetail> {
  Future<DetailMember> _member;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  didChangeDependencies() {
    _member = Provider.of<MembersProvider>(context).getMember(widget.pk);
    super.didChangeDependencies();
  }

  void _showSnackbar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 1),
    ));
  }

  Widget _fieldLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }

  Widget _achievementTile(Achievement achievement, bool first) {
    Widget periodCol;
    if (achievement.periods != null) {
      periodCol = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: achievement.periods.map((Period period) {
          DateFormat formatter = DateFormat("d MMMM y");
          String since = formatter.format(period.since);
          String until =
              period.until != null ? formatter.format(period.since) : "Present";
          String dates = "$since - $until";
          String leader = "";
          if (period.chair) {
            leader = "Chair: ";
          } else if (period.role != null) {
            leader = "${period.role}: ";
          }
          return Text("$leader$dates");
        }).toList(),
      );
    } else {
      periodCol = null;
    }

    Widget tile = ListTile(
      title: Text(
        achievement.name,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      subtitle: periodCol,
      contentPadding: EdgeInsets.zero,
    );

    return Column(
      children: first ? [tile] : [const Divider(height: 0), tile],
    );
  }

  List<Widget> _makeFacts(DetailMember member) {
    List<Widget> facts = [];

    facts.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 5),
          _fieldLabel("About ${member.displayName}"),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              member.profileDescription?.isNotEmpty ?? false
                  ? member.profileDescription
                  : "This member hasn't created a description yet.",
              style: TextStyle(
                fontStyle: member.profileDescription?.isNotEmpty ?? false
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ));

    facts.add(const Divider(
      height: 3,
      indent: 20,
      endIndent: 20,
    ));

    if ((member.programme?.isNotEmpty ?? false) &&
        member.startingYear != null) {
      facts.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _fieldLabel("Study programme")),
                Flexible(child: _fieldLabel("Cohort")),
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
                      // TODO: map to real programme names
                      member.programme,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      member.startingYear.toString(),
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ));

      facts.add(const Divider(
        height: 3,
        indent: 20,
        endIndent: 20,
      ));
    }

    if (member.birthday?.isNotEmpty ?? false) {
      facts.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            _fieldLabel("Birthday"),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                member.birthday,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ));

      facts.add(const Divider(
        height: 3,
        indent: 20,
        endIndent: 20,
      ));
    }

    if (member.website?.isNotEmpty ?? false) {
      facts.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            _fieldLabel("Website"),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () async {
                  if (await canLaunch(member.website)) {
                    await launch(member.website);
                  } else {
                    _showSnackbar("${member.website} can not be opened.");
                  }
                },
                child: Text(
                  member.website,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ));

      facts.add(const Divider(
        height: 3,
        indent: 20,
        endIndent: 20,
      ));
    }

    if (member.achievements?.isNotEmpty ?? false) {
      facts.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            _fieldLabel("Achievements for Thalia"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: List.generate(
                  member.achievements.length,
                  (index) =>
                      _achievementTile(member.achievements[index], index == 0),
                ),
              ),
            ),
          ],
        ),
      ));

      facts.add(const Divider(
        height: 3,
        indent: 20,
        endIndent: 20,
      ));
    }

    if (member.societies?.isNotEmpty ?? false) {
      facts.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            _fieldLabel("Societies"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: List.generate(
                  member.societies.length,
                  (index) =>
                      _achievementTile(member.societies[index], index == 0),
                ),
              ),
            ),
          ],
        ),
      ));

      facts.add(const Divider(
        height: 3,
        indent: 20,
        endIndent: 20,
      ));
    }

    return facts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _member,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DetailMember member = snapshot.data;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(member.displayName),
                    background: GestureDetector(
                      onTap: () {},
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: widget.pk,
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/img/default-avatar.jpg',
                              image: member.avatar.full,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                          Container(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(_makeFacts(member)),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // TODO: handle error
            return Center(child: Text("error" + snapshot.error.toString()));
          } else {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.listMember?.displayName ?? "Profile"),
                    background: GestureDetector(
                      onTap: () {
                        // TODO: open image modal
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: widget.pk,
                            child: widget.listMember != null
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/img/default-avatar.jpg',
                                    image: widget.listMember.avatar.full,
                                    fit: BoxFit.cover,
                                    fadeInDuration:
                                        const Duration(milliseconds: 300),
                                  )
                                : Image.asset(
                                    'assets/img/default-avatar.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Container(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
