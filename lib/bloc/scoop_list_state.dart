part of 'scoop_list_bloc.dart';

@immutable
abstract class ScoopListState extends Equatable {
  const ScoopListState();

  @override
  List<Object> get props => [];
}

class ScoopListInitial extends ScoopListState {}

class ScoopNotFound extends ScoopListState {}

class ScoopListLoading extends ScoopListState {}

class ScoopLocalAppList extends ScoopListState {
  final List<ScoopAppModel> apps;

  const ScoopLocalAppList(this.apps);

  @override
  List<Object> get props => [apps];
}

class ScoopUpdateInProgress extends ScoopListState {
  final String message;

  const ScoopUpdateInProgress(this.message);

  @override
  List<Object> get props => [message];
}

class ScoopUpdateError extends ScoopListState {
  final String message;

  const ScoopUpdateError(this.message);

  @override
  List<Object> get props => [message];
}
