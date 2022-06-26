import 'package:reaxit/models/event.dart';

class FakeEvent implements BaseEvent {
  @override
  final int pk;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime start;
  @override
  final DateTime end;
  @override
  final String location;

  FakeEvent({
    required this.pk,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.location,
  });
}
