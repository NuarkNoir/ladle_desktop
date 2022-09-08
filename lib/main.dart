import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ladle/bloc/scoop_list_bloc.dart';
import 'package:system_theme/system_theme.dart';

import 'app.dart';

void main() async {
  final binding =
      WidgetsFlutterBinding.ensureInitialized() as WidgetsFlutterBinding;

  await SystemTheme.accentColor.load();

  doWhenWindowReady(() {
    const initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Ladle';
    appWindow.show();
  });

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => ScoopListBloc(),
      ),
    ],
    child: const LadleApp(),
  ));
}
