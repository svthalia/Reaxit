import 'package:flutter/material.dart';
import 'package:reaxit/providers/members_provider.dart';
import 'package:reaxit/ui/components/member_card.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/network_scrollable_wrapper.dart';

class MemberList extends StatelessWidget {
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
      body: NetworkScrollableWrapper<MembersProvider>(
        builder: (context, members, child) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
          ),
          itemCount: members.memberList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) =>
              MemberCard(members.memberList[index]),
        ),
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
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: NetworkScrollableWrapper<MembersProvider>(
        builder: (context, members, child) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
          ),
          itemCount: members.memberList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) =>
              MemberCard(members.memberList[index]),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      child: NetworkScrollableWrapper<MembersProvider>(
        builder: (context, members, child) => GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
          ),
          itemCount: members.memberList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) =>
              MemberCard(members.memberList[index]),
        ),
      ),
    );
  }
}
