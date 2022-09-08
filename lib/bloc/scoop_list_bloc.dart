import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'scoop_list_event.dart';
part 'scoop_list_state.dart';

class ScoopListBloc extends Bloc<ScoopListEvent, ScoopListState> {
  ScoopListBloc() : super(ScoopListInitial()) {
    on<ScoopListEvent>((event, emit) {});
  }
}
