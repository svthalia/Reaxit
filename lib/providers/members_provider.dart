import 'dart:convert';

import 'package:reaxit/models/member.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class MembersProvider extends ApiSearchService {
  List<Member> _memberList = [];

  List<Member> get memberList => _memberList;

  MembersProvider(AuthProvider authProvider) : super(authProvider);

  Future<void> load() async {
    status = ApiStatus.LOADING;
    notifyListeners();
    try {
      String response = await this.get("/members/");
      List<dynamic> jsonMembers = jsonDecode(response)['results'];
      _memberList =
          jsonMembers.map((jsonMember) => Member.fromJson(jsonMember)).toList();
      status = ApiStatus.DONE;
      notifyListeners();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }

  Future<Member> getMember(int pk) async {
    try {
      String response = await this.get("/members/$pk");
      return Member.fromJson(jsonDecode(response));
    } on ApiException catch (_) {
      // TODO: handle 404 separately (can probably throw exception to be caught by futurbuilder's snapshot.hasError)
      notifyListeners();
    }
  }

  @override
  Future<List<Member>> search(String query) async {
    try {
      String response = await this.get(
        "/members/?search=${Uri.encodeComponent(query)}",
      );
      List<dynamic> jsonMembers = jsonDecode(response)['results'];
      return jsonMembers
          .map((jsonMember) => Member.fromJson(jsonMember))
          .toList();
    } on ApiException catch (_) {
      notifyListeners();
    }
  }
}
