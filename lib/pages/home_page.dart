import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/scoop_list_bloc.dart';
import '../widgets/windows_buttons_widget.dart';
import 'app_list_fragment.dart';
import 'app_search_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _fragmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoopListBloc, ScoopListState>(
      builder: (context, state) {
        if (state is ScoopNotFound) {
          return _appWithoutScoopInstalled();
        }
        return NavigationView(
          appBar: _buildAppbar(state),
          pane: _buildNavigationPane(),
          content: _buildContent(state),
        );
      },
    );
  }

  Widget _appWithoutScoopInstalled() {
    return NavigationView(
      appBar: NavigationAppBar(
        title: MoveWindow(
          child: const Align(
            alignment: Alignment.center,
            child: Text("Ladle"),
          ),
        ),
        actions: MoveWindow(
          child: Row(children: const [
            Spacer(),
            WindowButtons(),
          ]),
        ),
        automaticallyImplyLeading: false,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Scoop not found!\nYou can find installation instructions here:",
            textAlign: TextAlign.center,
          ),
          Button(
            onPressed: () {
              launchUrl(Uri.parse("https://scoop.sh/"));
            },
            child: const Text("Scoop website"),
          ).padding(all: 10),
        ],
      ),
    );
  }

  NavigationAppBar _buildAppbar(ScoopListState state) {
    return NavigationAppBar(
      title: MoveWindow(
        child: const Align(
          alignment: Alignment.center,
          child: Text("Ladle"),
        ),
      ),
      actions: MoveWindow(
        child: Row(children: [
          const Spacer(),
          WindowButton(
            iconBuilder: (buttonContext) => Center(
              child: state is ScoopListLoading
                  ? const ProgressBar()
                  : const Icon(
                      FluentIcons.refresh,
                      size: 12,
                    ),
            ),
            onPressed: state is ScoopListLoading
                ? null
                : () =>
                    context.read<ScoopListBloc>().add(ScoopUpdateRequested()),
          ),
          WindowButton(
            iconBuilder: (buttonContext) => const Icon(
              FluentIcons.settings,
              size: 12,
            ),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          ),
          const WindowButtons(),
        ]),
      ),
      automaticallyImplyLeading: false,
    );
  }

  NavigationPane _buildNavigationPane() {
    return NavigationPane(
      selected: _fragmentIndex,
      displayMode: PaneDisplayMode.compact,
      onChanged: (i) => setState(() => _fragmentIndex = i),
      menuButton: const SizedBox(),
      items: [
        PaneItem(
          title: const Text("Home"),
          icon: const Icon(FluentIcons.home),
        ),
        PaneItem(
          title: const Text("Apps"),
          icon: const Icon(FluentIcons.apps_content),
        ),
      ],
      footerItems: [
        PaneItemSeparator(),
        PaneItem(
          title: const Text("Settings"),
          icon: const Icon(FluentIcons.settings),
        ),
      ],
    );
  }

  Widget _buildContent(ScoopListState state) {
    if (state is ScoopListLoading) {
      return const Center(child: ProgressBar());
    } else if (state is ScoopUpdateInProgress) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Updating Scoop").fontSize(24),
          Text(state.message).textColor(Colors.orange).italic(),
          const ProgressBar(),
        ],
      );
    } else if (state is ScoopUpdateError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Scoop update error").fontSize(24),
          Text(state.message).textColor(Colors.red).italic(),
        ],
      );
    }
    return NavigationBody(
      index: _fragmentIndex,
      children: const [
        AppListFragment(),
        AppSearchFragment(),
      ],
    );
  }
}
