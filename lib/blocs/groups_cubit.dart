import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/models.dart';

class GroupsState extends Equatable {
  /// These may be outdated when [isLoading] is true.
  final List<ListGroup> committees;

  /// These may be outdated when [isLoading] is true.
  final List<ListGroup> societies;

  /// These may be outdated when [isLoading] is true.
  final List<ListGroup> boards;

  final String? message;
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const GroupsState({
    required this.committees,
    required this.societies,
    required this.boards,
    required this.isLoading,
    required this.message,
  });

  @override
  List<Object?> get props => [
        committees,
        societies,
        boards,
        message,
        isLoading,
      ];

  GroupsState copyWith({
    List<ListGroup>? committees,
    List<ListGroup>? societies,
    List<ListGroup>? boards,
    bool? isLoading,
    String? message,
  }) =>
      GroupsState(
        committees: committees ?? this.committees,
        societies: societies ?? this.societies,
        boards: boards ?? this.boards,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  const GroupsState.result({
    required this.committees,
    required this.societies,
    required this.boards,
  })  : message = null,
        isLoading = false;

  const GroupsState.loading({
    required this.committees,
    required this.societies,
    required this.boards,
  })  : message = null,
        isLoading = false;

  const GroupsState.failure({required String this.message})
      : committees = const [],
        societies = const [],
        boards = const [],
        isLoading = false;
}
