import 'package:equatable/equatable.dart';

/// Base class of events for paginated lists.
///
/// You can extend this class to enable for instance search or ordering.
/// In that case, be sure to override [this.props] to reflect any new fields.
class ListEvent extends Equatable {
  final bool isLoad;
  final bool isMore;

  const ListEvent.load()
      : isLoad = true,
        isMore = false;

  const ListEvent.more()
      : isLoad = false,
        isMore = true;

  @override
  List<Object?> get props => [isLoad, isMore];
}
