import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../models/scoop_app_model.dart';
import '../utils/scoop_utils.dart';

part 'scoop_search_event.dart';
part 'scoop_search_state.dart';

class ScoopSearchBloc extends Bloc<ScoopSearchEvent, ScoopSearchState> {
  ScoopSearchBloc() : super(ScoopSearchInitial()) {
    on<ScoopSearchQueryChanged>(
      (event, emit) async {
        emit(ScoopSearchLoading());

        try {
          Map<String, List<ScoopAppModel>> data = {};
          if (event.query.isEmpty) {
            data = await getAllInstallableApps();
          } else {
            data = await searchInstallableApps(event.query);
          }
          emit(ScoopSearchLoaded(data));
        } catch (e) {
          emit(ScoopSearchError(e.toString()));
        }
      },
      transformer: restartable(),
    );
  }
}
