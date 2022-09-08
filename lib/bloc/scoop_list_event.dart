part of 'scoop_list_bloc.dart';

@immutable
abstract class ScoopListEvent extends Equatable {
  const ScoopListEvent();

  @override
  List<Object> get props => [];
}

class ScoopLocate extends ScoopListEvent {}

class ScoopUpdateRequested extends ScoopListEvent {}

class ScoopListRequested extends ScoopListEvent {}

class ScoopSearchRequested extends ScoopListEvent {
  final String query;

  const ScoopSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}
