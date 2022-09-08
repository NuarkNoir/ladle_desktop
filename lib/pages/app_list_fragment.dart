import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ladle/models/scoop_app_model.dart';
import 'package:ladle/utils/set_extension.dart';
import 'package:styled_widget/styled_widget.dart';

import '../bloc/scoop_list_bloc.dart';

class AppListFragment extends StatefulWidget {
  const AppListFragment({Key? key}) : super(key: key);

  @override
  State<AppListFragment> createState() => _AppListFragmentState();
}

class _AppListFragmentState extends State<AppListFragment> {
  final scrollController = ScrollController();
  final openedApps = <ScoopAppModel>{};
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.read<ScoopListBloc>().state;
    if (state is! ScoopLocalAppList) {
      return const Center(child: Text("No apps installed"));
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: AutoSuggestBox(
        items: state.apps.map((e) => e.name).toList(),
        leadingIcon: const Icon(FluentIcons.search).padding(all: 16),
        placeholder: "Search for apps",
        onSelected: (value) {
          final app = state.apps.firstWhere((e) => e.name == value);
          setState(() {
            openedApps.add(app);
          });
        },
      ),
      content: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              key: PageStorageKey(state.apps.length),
              controller: scrollController,
              itemCount: state.apps.length,
              itemBuilder: (context, index) =>
                  _createAppWidget(state.apps[index]),
            ).backgroundColor(Colors.black.withAlpha(50)),
          ),
          Expanded(
            flex: 3,
            child: TabView(
              wheelScroll: true,
              currentIndex: currentIndex,
              onChanged: (index) => setState(() => currentIndex = index),
              tabs: openedApps
                  .map((e) => Tab(
                        text: Text(e.name),
                        closeIcon: FluentIcons.chrome_close,
                        onClosed: () => setState(
                          () {
                            final appIdx = openedApps.indexOf(e);
                            if (appIdx < currentIndex) {
                              currentIndex--;
                            } else {
                              currentIndex = 0;
                            }
                            openedApps.remove(e);
                          },
                        ),
                      ))
                  .toList(growable: false),
              bodies: openedApps.map(_createAppPage).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createAppWidget(ScoopAppModel appModel) {
    return GestureDetector(
      onTap: () => setState(() {
        if (openedApps.contains(appModel)) {
          currentIndex = openedApps.indexOf(appModel);
        } else {
          openedApps.add(appModel);
          currentIndex = openedApps.length - 1;
        }
      }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appModel.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat("dd.MM.yyyy hh:mm")
                            .format(appModel.updatedAt),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    appModel.description,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        FluentIcons.repo_solid,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        appModel.bucket,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createAppPage(ScoopAppModel appModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appModel.name).fontSize(32).bold().paddingDirectional(bottom: 16),
        Row(
          children: [
            Chip(
              image: const Icon(FluentIcons.repo_solid),
              text: Text(appModel.bucket),
            ).padding(right: 8),
            Chip.selected(
              image: const Icon(FluentIcons.calendar),
              text: Text(
                  DateFormat("dd.MM.yyyy hh:mm").format(appModel.updatedAt)),
            ).padding(right: 8),
            OutlinedButton(
              child: const Text("Update"),
              onPressed: () => _runScoopRoutine(
                title: "Updating ${appModel.name}",
                params: ["update", appModel.name],
              ),
            ).padding(right: 8),
            OutlinedButton(
              child: const Text("Reinstall"),
              onPressed: () => _runScoopRoutine(
                title: "Reinstalling ${appModel.name}",
                executable: "powershell",
                params: [
                  "-c",
                  "scoop",
                  "uninstall",
                  appModel.name,
                  "&&",
                  "scoop",
                  "install",
                  appModel.name
                ],
              ).then((_) =>
                  context.read<ScoopListBloc>().add(ScoopListRequested())),
            ).padding(right: 8),
            OutlinedButton(
              child: const Text("Uninstall"),
              onPressed: () => _runScoopRoutine(
                title: "Uninstalling ${appModel.name}",
                params: ["uninstall", appModel.name],
              ).then((_) =>
                  context.read<ScoopListBloc>().add(ScoopListRequested())),
            ),
          ],
        ).paddingDirectional(bottom: 16),
        Text(
          appModel.description,
          style: FluentTheme.of(context).typography.body,
        ),
      ],
    ).padding(all: 16);
  }

  Future<void> _runScoopRoutine({
    String executable = "scoop",
    required String title,
    required List<String> params,
  }) async {
    final textController = TextEditingController();
    final textScroller = ScrollController();
    final process = await Process.start(executable, params, runInShell: true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        textController.text = "Waiting for process to start...\n";
        process.stdout.transform(utf8.decoder).forEach((element) {
          element = element.trim();
          if (element.isEmpty) return;
          textController.text +=
              "${DateFormat("hh:mm:ss").format(DateTime.now())} $element\n";
          textScroller.jumpTo(textScroller.position.maxScrollExtent);
        });
        process.stderr.transform(utf8.decoder).forEach((element) {
          element = element.trim();
          if (element.isEmpty) return;
          textController.text +=
              "${DateFormat("hh:mm:ss").format(DateTime.now())} stderr: $element\n";
          textScroller.jumpTo(textScroller.position.maxScrollExtent);
        });
        return FutureBuilder<int>(
          future: process.exitCode,
          builder: (context, snapshot) {
            return ContentDialog(
              constraints: const BoxConstraints(minWidth: 1000),
              title: Text(title),
              content: TextBox(
                enabled: false,
                maxLines: 5,
                minLines: 5,
                controller: textController,
                scrollController: textScroller,
                scrollPhysics: snapshot.hasData
                    ? null
                    : const NeverScrollableScrollPhysics(),
              ),
              actions: snapshot.hasData
                  ? [
                      Button(
                        child: const Text("Close"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ]
                  : [
                      Button(
                        child: const Text("Cancel"),
                        onPressed: () {
                          process.kill();
                          Navigator.pop(context);
                        },
                      )
                    ],
            );
          },
        );
      },
    );
    process.kill();
  }
}
