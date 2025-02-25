import 'package:json_annotation/json_annotation.dart';

part 'list_response.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  genericArgumentFactories: true,
)
class ListResponse<T> {
  /// The total number of elements that can be returned.
  final int count;

  /// The list of elements returned.
  final List<T> results;

  const ListResponse(this.count, this.results);

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ListResponseFromJson<T>(json, fromJsonT);
}
