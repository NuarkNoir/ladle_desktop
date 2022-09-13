part of 'scoop_search_bloc.dart';

abstract class ScoopSearchEvent extends Equatable {
  const ScoopSearchEvent();

  @override
  List<Object> get props => [];
}

class ScoopSearchQueryChanged extends ScoopSearchEvent {
  final String query;

  const ScoopSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}
