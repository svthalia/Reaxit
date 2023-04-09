import 'package:reaxit/models.dart';

class FakeEvent implements BaseEvent {
  @override
  final int pk;
  @override
  final String title;
  @override
  final List<Group> organisers;
  @override
  final String caption;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final String location;

  FakeEvent({
    required this.pk,
    required this.title,
    this.organisers = const [],
    required this.caption,
    required this.start,
    required this.end,
    required this.location,
  });
}
