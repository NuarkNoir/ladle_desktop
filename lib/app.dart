import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';

import 'pages.dart';

class LadleApp extends StatelessWidget {
  const LadleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Ladle',
      theme: ThemeData.light()
        ..copyWith(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        ),
      darkTheme: ThemeData.dark()
        ..copyWith(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        ),
      onGenerateRoute: _generateRoutes,
    );
  }

  Route? _generateRoutes(RouteSettings settings) {
    if (settings.name == '/') {
      return FluentPageRoute(
        builder: (context) => const HomePage(),
      );
    }

    throw Exception('Invalid route: ${settings.name}');
  }
}
