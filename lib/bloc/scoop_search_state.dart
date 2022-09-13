part of 'scoop_search_bloc.dart';

abstract class ScoopSearchState extends Equatable {
  const ScoopSearchState();

  @override
  List<Object> get props => [];
}

class ScoopSearchInitial extends ScoopSearchState {}

class ScoopSearchLoading extends ScoopSearchState {}

class ScoopSearchLoaded extends ScoopSearchState {
  final Map<String, List<ScoopAppModel>> apps;

  const ScoopSearchLoaded(this.apps);

  @override
  List<Object> get props => [apps];
}

class ScoopSearchError extends ScoopSearchState {
  final String message;

  const ScoopSearchError(this.message);

  @override
  List<Object> get props => [message];
}
