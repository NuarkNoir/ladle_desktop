import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../widgets/windows_buttons_widget.dart';
import 'app_list_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _fragmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: _buildAppbar(),
      pane: _buildNavigationPane(),
      content: _buildContent(),
    );
  }

  NavigationAppBar _buildAppbar() {
    return NavigationAppBar(
      title: MoveWindow(
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Ladle"),
        ),
      ),
      actions: MoveWindow(
        child: Row(children: const [Spacer(), WindowButtons()]),
      ),
      automaticallyImplyLeading: false,
    );
  }

  NavigationPane _buildNavigationPane() {
    return NavigationPane(
      selected: _fragmentIndex,
      displayMode: PaneDisplayMode.top,
      onChanged: (i) => setState(() => _fragmentIndex = i),
      items: [
        PaneItem(
          title: const Text("Home"),
          icon: const Icon(FluentIcons.home),
        ),
        PaneItem(
          title: const Text("Updates"),
          icon: const Icon(FluentIcons.update_restore),
        ),
        PaneItemSeparator(),
        PaneItem(
          title: const Text("Settings"),
          icon: const Icon(FluentIcons.settings),
        ),
      ],
    );
  }

  NavigationBody _buildContent() {
    return NavigationBody(
      index: _fragmentIndex,
      children: const [
        AppListFragment(),
        Center(child: Text("Scoops")),
        Center(child: Text("Settings")),
      ],
    );
  }
}
