import 'package:flutter/material.dart';
import 'package:reaxit/providers/members_provider.dart';
import 'package:reaxit/ui/components/member_card.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/network_scrollable_wrapper.dart';
import 'package:reaxit/ui/components/network_search_delegate.dart';

class MemberList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search for members",
            onPressed: () {
              showSearch(
                context: context,
                delegate: NetworkSearchDelegate<MembersProvider>(
                  resultBuilder: (context, memberList, child) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                      ),
                      itemCount: memberList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemBuilder: (context, index) =>
                          MemberCard(memberList[index]),
                    );
                  },
                ),
              );
            },
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
