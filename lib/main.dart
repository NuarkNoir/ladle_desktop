import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ladle/bloc/scoop_list_bloc.dart';
import 'package:system_theme/system_theme.dart';

import 'app.dart';
import 'bloc/scoop_search_bloc.dart';

void main() async {
  final binding =
      WidgetsFlutterBinding.ensureInitialized() as WidgetsFlutterBinding;

  await SystemTheme.accentColor.load();

  Intl.defaultLocale = 'en_US';

  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Ladle';
    appWindow.show();
  });

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ScoopListBloc()..add(ScoopLocate()),
      ),
      BlocProvider(
        create: (context) => ScoopSearchBloc()..add(ScoopSearchReload()),
      ),
    ],
    child: const LadleApp(),
  ));
}
