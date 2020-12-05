import 'package:flutter/material.dart';

class MemberDetail extends StatefulWidget {
  final int _pk;
  MemberDetail(this._pk);

  @override
  _MemberDetailState createState() => _MemberDetailState(this._pk);
}

class _MemberDetailState extends State<MemberDetail> {
  bool loading = false;
  final int _pk;
  _Member _member = _Member(37, "Dirk Doesburg", "Haai",
      "http://via.placeholder.com/640x360", "Member", 2019);

  _MemberDetailState(this._pk);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
          body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Profile"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            // expandedHeight: 200,
            pinned: true,
          ),
          SliverFillRemaining(
            child: Column(
                // children: [Text(this._member.display_name)],
                ),
          )
        ],
      ));
    } else {
      return Scaffold(
          body: CustomScrollView(
        slivers: [
          SliverAppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(this._member.display_name),
                  background: GestureDetector(
                      onTap: () async {
                        await showDialog(
                            context: context,
                            builder: (_) => ImageDialog(this._member.avatar));
                      },
                      child: Stack(fit: StackFit.expand, children: [
                        Hero(
                          tag: this._pk,
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/img/default-avatar.jpg',
                              image: this._member.avatar,
                              fit: BoxFit.cover,
                              fadeInDuration:
                                  const Duration(milliseconds: 300)),
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
                                    stops: [
                                      0.5,
                                      1.0
                                    ])))
                      ])))),
          SliverFillRemaining(
            child: Column(
              children: [],
            ),
          )
        ],
      ));
    }
  }
}

class _Member {
  final int pk;
  final String display_name;
  final String description;
  final String avatar;
  final String membership_type;
  final int starting_year;

  _Member(this.pk, this.display_name, this.description, this.avatar,
      this.membership_type, this.starting_year);
}

class ImageDialog extends StatelessWidget {
  final String _image;

  ImageDialog(this._image);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(),
    );
  }
}
