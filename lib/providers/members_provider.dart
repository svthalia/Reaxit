import 'dart:convert';

import 'package:reaxit/models/member.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class MembersProvider extends ApiService {
  List<Member> _memberList = [];
  List<Member> get memberList => _memberList;

  MembersProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    _memberList = await _getMembers();
  }

  Future<List<Member>> _getMembers() async {
    String response = await this.get("/members/");
    List<dynamic> jsonMembers = jsonDecode(response)['results'];
    return jsonMembers
        .map((jsonMember) => Member.fromJson(jsonMember))
        .toList();
  }

  Future<List<Member>> search(String query) async {
    String response = await this.get(
      "/members/?search=${Uri.encodeComponent(query)}",
    );
    List<dynamic> jsonMembers = jsonDecode(response)['results'];
    return jsonMembers
        .map((jsonMember) => Member.fromJson(jsonMember))
        .toList();
  }

  Future<Member> getMember(int pk) async {
    String response = await this.get("/members/$pk");
    return Member.fromJson(jsonDecode(response));
  }
}
