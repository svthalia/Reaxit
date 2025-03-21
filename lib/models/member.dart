import 'package:json_annotation/json_annotation.dart';
import 'package:reaxit/models.dart';

part 'member.g.dart';

enum Programme { computingscience, informationscience }

enum MembershipType { member, benefactor, honorary }

enum DisplayNamePreference {
  full,
  nickname,
  firstname,
  initials,
  fullnick,
  nicklast,
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ListMember {
  final int pk;
  final MembershipType? membershipType;
  final Profile profile;

  String get displayName => profile.displayName;
  String get shortDisplayName => profile.shortDisplayName;
  DateTime? get birthday => profile.birthday;
  Photo get photo => profile.photo;
  Programme? get programme => profile.programme;
  int? get startingYear => profile.startingYear;
  Uri? get website => profile.website;
  String? get profileDescription => profile.profileDescription;

  const ListMember(this.pk, this.membershipType, this.profile);

  factory ListMember.fromJson(Map<String, dynamic> json) =>
      _$ListMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ListMemberToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminListMember extends ListMember {
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';

  const AdminListMember(
    super.pk,
    super.membershipType,
    super.profile,
    this.firstName,
    this.lastName,
  );

  factory AdminListMember.fromJson(Map<String, dynamic> json) =>
      _$AdminListMemberFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Member extends ListMember {
  final List<Achievement> achievements;
  final List<Achievement> societies;

  const Member(
    super.pk,
    super.membershipType,
    super.profile,
    this.achievements,
    this.societies,
  );

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FullMember extends Member {
  @override
  // ignore: overridden_fields
  final FullProfile profile;

  const FullMember(
    int pk,
    MembershipType? membershipType,
    this.profile,
    List<Achievement> achievements,
    List<Achievement> societies,
  ) : super(pk, membershipType, profile, achievements, societies);

  factory FullMember.fromJson(Map<String, dynamic> json) =>
      _$FullMemberFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  final String displayName;
  final String shortDisplayName;
  final DateTime? birthday;
  final Photo photo;
  final Programme? programme;
  final int? startingYear;
  @JsonKey(fromJson: _nonEmptyUriFromJson)
  final Uri? website;
  final String? profileDescription;

  const Profile(
    this.displayName,
    this.shortDisplayName,
    this.birthday,
    this.photo,
    this.programme,
    this.startingYear,
    this.website,
    this.profileDescription,
  );

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FullProfile extends Profile {
  final String? addressStreet;
  final String? addressStreet2;
  final String? addressPostalCode;
  final String? addressCity;
  final String? addressCountry;
  final String? phoneNumber;
  final String? emergencyContact;
  final String? emergencyContactPhoneNumber;

  final bool showBirthday;

  final String? initials;
  final String? nickname;
  final DisplayNamePreference displayNamePreference;

  const FullProfile(
    super.displayName,
    super.shortDisplayName,
    super.birthday,
    super.photo,
    super.programme,
    super.startingYear,
    super.website,
    super.profileDescription,
    this.addressStreet,
    this.addressStreet2,
    this.addressPostalCode,
    this.addressCity,
    this.addressCountry,
    this.phoneNumber,
    this.emergencyContact,
    this.emergencyContactPhoneNumber,
    this.showBirthday,
    this.initials,
    this.nickname,
    this.displayNamePreference,
  );

  factory FullProfile.fromJson(Map<String, dynamic> json) =>
      _$FullProfileFromJson(json);
}

@JsonSerializable()
class Period {
  final DateTime since;
  final DateTime? until;
  final bool chair;
  final String? role;
  const Period(this.since, this.until, this.chair, this.role);
  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);
}

@JsonSerializable()
class Achievement {
  final String name;
  final DateTime earliest;

  final bool? active;
  final DateTime? latest;
  final List<Period>? periods;

  final int? pk;
  final Uri? url;

  const Achievement(
    this.name,
    this.periods,
    this.pk,
    this.active,
    this.url,
    this.earliest,
    this.latest,
  );
  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

Uri? _nonEmptyUriFromJson(String? json) {
  if (json == null || json.isEmpty) return null;
  return Uri.tryParse(json);
}
