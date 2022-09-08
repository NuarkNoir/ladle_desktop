import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/scoop_app_model.dart';
import '../utils/scoop_utils.dart';

part 'scoop_list_event.dart';
part 'scoop_list_state.dart';

class ScoopListBloc extends Bloc<ScoopListEvent, ScoopListState> {
  ScoopListBloc() : super(ScoopListInitial()) {
    on<ScoopLocate>(
      (event, emit) {
        if (scoopInstalled()) {
          add(ScoopListRequested());
        } else {
          emit(ScoopNotFound());
        }
      },
      transformer: droppable(),
    );
    on<ScoopUpdateRequested>(
      (event, emit) async {
        try {
          final process =
              await Process.start('scoop', ["update"], runInShell: true);
          await process.stdout.transform(utf8.decoder).forEach((e) {
            emit(ScoopUpdateInProgress(e));
          });
          int exitCode = await process.exitCode;
          if (exitCode != 0) {
            throw Exception(
                "Command `scoop update` failed with code $exitCode");
          }
          add(ScoopListRequested());
        } catch (e) {
          emit(ScoopUpdateError(e.toString()));
        }
      },
      transformer: droppable(),
    );
    on<ScoopListRequested>(
      (event, emit) async {
        emit(ScoopListLoading());
        final apps = await getInstalledScoopApps();
        emit(ScoopLocalAppList(apps));
      },
      transformer: droppable(),
    );
  }
}
