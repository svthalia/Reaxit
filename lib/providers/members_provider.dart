import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class MembersProvider extends ApiSearchService {
  List<Member> _memberList = [];

  List<Member> get memberList => _memberList;

  MembersProvider(AuthProvider authProvider) : super(authProvider);

  Future<void> load() async {
    if (authProvider.status == Status.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper
            .get('https://staging.thalia.nu/api/v1/members/');
        if (response.statusCode == 200) {
          List<dynamic> jsonMemberList = jsonDecode(response.body)['results'];
          _memberList = jsonMemberList
              .map((jsonMember) => Member.fromJson(jsonMember))
              .toList();
          status = ApiStatus.DONE;
        } else if (response.statusCode == 403)
          status = ApiStatus.NOT_AUTHENTICATED;
        else
          status = ApiStatus.UNKNOWN_ERROR;
      } on SocketException catch (_) {
        status = ApiStatus.NO_INTERNET;
      } catch (_) {
        status = ApiStatus.UNKNOWN_ERROR;
      }

      notifyListeners();
    }
  }

  // TODO: proper error handling of getMember and search
  Future<Member> getMember(int pk) async {
    if (authProvider.status == Status.SIGNED_IN) {
      Response response = await authProvider.helper
          .get('https://staging.thalia.nu/api/v1/members/$pk');
      if (response.statusCode == 200) {
        return Member.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 204) {
        throw ("No result");
      } else {
        throw ("Something else");
      }
    } else {
      throw ("Not logged in");
    }
  }

  @override
  Future<List<Member>> search(String query) async {
    if (authProvider.status == Status.SIGNED_IN) {
      Response response = await authProvider.helper.get(
          'https://staging.thalia.nu/api/v1/members/?search=${Uri.encodeComponent(query)}');
      if (response.statusCode == 200) {
        List<dynamic> jsonMemberList = jsonDecode(response.body)['results'];
        return jsonMemberList
            .map((jsonMember) => Member.fromJson(jsonMember))
            .toList();
      } else if (response.statusCode == 204) {
        throw ("No result");
      } else {
        throw ("Something else");
      }
    } else {
      throw ("Not logged in");
    }
  }
}
