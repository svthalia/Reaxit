import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/screens/member_detail.dart';

class MemberList extends StatefulWidget {
  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  bool loading = true;
  List<_ListMember> _members = [
    _ListMember(37, "Dirk Doesburg", "http://via.placeholder.com/640x360",
        "Member", 2019),
    _ListMember(69, "Lars 'Lil' cuckboy' van Rhijn",
        "http://via.placeholder.com/640x360", "Member", 1999),
    _ListMember(420, "Jen Dusseljee", "http://via.placeholder.com/640x360",
        "Member", 2017),
    _ListMember(370, "Dirk Doesburg", "http://via.placeholder.com/640x360",
        "Member", 2019),
    _ListMember(690, "Lars 'Lil' cuckboy' van Rhijn",
        "http://via.placeholder.com/640x360", "Member", 1999),
  ];

  Future<void> _refresh() async {
    await print("TODO: reload members");
    loading = false;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Members'),
          actions: [
            IconButton(
              tooltip: "Search for members",
              onPressed: () {
                showSearch(context: context, delegate: _MemberSearch());
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        drawer: MenuDrawer(),
        body: RefreshIndicator(
            onRefresh: this._refresh,
            // TODO: list if not loading, loading indicator otherwise
            child: GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                children: this._members.map((e) => _MemberCard(e)).toList())));
  }
}

class _ListMember {
  final int pk;
  final String display_name;
  final String avatar;
  final String membership_type;
  final int starting_year;

  _ListMember(this.pk, this.display_name, this.avatar, this.membership_type,
      this.starting_year);
}

class _MemberCard extends StatelessWidget {
  final _ListMember _member;
  _MemberCard(this._member);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberDetail(this._member.pk)));
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: this._member.pk,
            child: FadeInImage.assetNetwork(
                placeholder: 'assets/img/default-avatar.jpg',
                image: this._member.avatar,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300)),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            child: Text(
              this._member.display_name,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.black,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: [
                      0.5,
                      1.0
                    ])),
          )
        ],
      ),
    );
  }
}

class _MemberSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          tooltip: "Clear search bar",
          icon: Icon(Icons.close),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(child: Text("TODO: search results for: $query")),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      child: Center(child: Text("TODO: suggestions (all members) $query")),
    );
  }
}
