import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../models/scoop_app_model.dart';
import '../utils/scoop_utils.dart';

part 'scoop_search_event.dart';
part 'scoop_search_state.dart';

class ScoopSearchBloc extends Bloc<ScoopSearchEvent, ScoopSearchState> {
  final Map<String, List<ScoopAppModel>> _cachedApps = {};

  ScoopSearchBloc() : super(ScoopSearchInitial()) {
    on<ScoopSearchReload>(
      (event, emit) async {
        _cachedApps.clear();
        try {
          Map<String, List<ScoopAppModel>> data = await getAllInstallableApps();
          _cachedApps.addAll(data);
          emit(ScoopSearchLoaded(data));
        } catch (e) {
          emit(const ScoopSearchLoaded({}));
        }
      },
      transformer: droppable(),
    );
    on<ScoopSearchQueryChanged>(
      (event, emit) async {
        emit(ScoopSearchLoading());

        try {
          Map<String, List<ScoopAppModel>> data = {};
          if (_cachedApps.isEmpty) {
            _cachedApps.addAll(await getAllInstallableApps());
          }

          if (event.query.isNotEmpty) {
            for (final bucket in _cachedApps.keys) {
              data[bucket] = _cachedApps[bucket]
                      ?.where((app) =>
                          app.name
                              .toLowerCase()
                              .contains(event.query.toLowerCase()) ||
                          app.description
                              .toLowerCase()
                              .contains(event.query.toLowerCase()))
                      .toList() ??
                  [];
            }
          } else {
            data.addAll(_cachedApps);
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
