import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ladle/bloc/scoop_search_bloc.dart';
import 'package:ladle/models/scoop_app_model.dart';
import 'package:ladle/utils/scoop_utils.dart';
import 'package:ladle/utils/set_extension.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../bloc/scoop_list_bloc.dart';

class AppSearchFragment extends StatefulWidget {
  const AppSearchFragment({Key? key}) : super(key: key);

  @override
  State<AppSearchFragment> createState() => _AppSearchFragmentState();
}

class _AppSearchFragmentState extends State<AppSearchFragment> {
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  final openedApps = <ScoopAppModel>{};
  int currentIndex = 0;

  String _previousSearch = '';

  @override
  void initState() {
    super.initState();
    searchController.text = _previousSearch;
    searchController.addListener(() {
      if (_previousSearch != searchController.text) {
        _previousSearch = searchController.text;
        context
            .read<ScoopSearchBloc>()
            .add(ScoopSearchQueryChanged(searchController.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoopSearchBloc, ScoopSearchState>(
      builder: (context, state) {
        Widget body;
        if (state is ScoopSearchLoading) {
          body = _buildLoadingBody();
        } else if (state is ScoopSearchLoaded) {
          body = _buildLoadedBody(state);
        } else if (state is ScoopSearchError) {
          body = _buildErrorBody(state);
        } else {
          body = _buildInitialBody();
        }
        return ScaffoldPage(
          padding: EdgeInsets.zero,
          header: TextBox(
            controller: searchController,
            placeholder: "Search for apps",
          ),
          content: body,
        );
      },
    );
  }

  Widget _buildLoadingBody() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: const Center(
            child: ProgressBar(),
          ).backgroundColor(Colors.black.withAlpha(50)),
        ),
        const Expanded(
          flex: 3,
          child: Center(
            child: ProgressBar(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedBody(ScoopSearchLoaded state) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            key: PageStorageKey(state.apps.length),
            controller: scrollController,
            itemCount: state.apps["main"]?.length ?? 0,
            itemBuilder: (context, index) =>
                _createAppWidget(state.apps["main"]![index]),
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
    );
  }

  Widget _buildErrorBody(ScoopSearchError state) {
    return Text(state.message).center();
  }

  Widget _buildInitialBody() {
    return const Text("Search for apps using input above").center();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(appModel.name).fontSize(32).bold(),
            Text(appModel.version).padding(all: 4)
          ],
        ).paddingDirectional(bottom: 16),
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
            FutureBuilder<bool>(
              future: checkAppInstalled(appModel),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  if (data != null && data) {
                    return Row(children: _buttonsForInstalledApp(appModel));
                  } else {
                    return Row(children: _buttonsForNotInstalledApp(appModel));
                  }
                } else if (snapshot.hasError) {
                  return Chip(
                    image: const Icon(FluentIcons.error),
                    text: Text(snapshot.error.toString()),
                  ).padding(right: 8);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ).paddingDirectional(bottom: 8),
        Row(
          children: [
            OutlinedButton(
                child: const Text("Homepage"),
                onPressed: () {
                  launchUrlString(appModel.homepage);
                }).padding(right: 8),
          ],
        ).paddingDirectional(bottom: 16),
        Text(
          appModel.description,
          style: FluentTheme.of(context).typography.body,
        ),
      ],
    ).padding(all: 16);
  }

  List<Widget> _buttonsForInstalledApp(ScoopAppModel appModel) {
    return [
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
        ).then((_) {
          context
              .read<ScoopSearchBloc>()
              .add(ScoopSearchQueryChanged(searchController.text));
        }),
      ).padding(right: 8),
      OutlinedButton(
        child: const Text("Uninstall"),
        onPressed: () => _runScoopRoutine(
          title: "Uninstalling ${appModel.name}",
          params: ["uninstall", appModel.name],
        ).then((_) {
          context
              .read<ScoopSearchBloc>()
              .add(ScoopSearchQueryChanged(searchController.text));
        }),
      ),
    ];
  }

  List<Widget> _buttonsForNotInstalledApp(ScoopAppModel appModel) {
    return [
      OutlinedButton(
        child: const Text("Install"),
        onPressed: () => _runScoopRoutine(
          title: "Installing ${appModel.name}",
          executable: "scoop",
          params: ["install", appModel.name],
        ).then((_) {
          context
              .read<ScoopSearchBloc>()
              .add(ScoopSearchQueryChanged(searchController.text));
        }),
      ).padding(right: 8),
    ];
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
          if (textScroller.hasClients) {
            textScroller.jumpTo(textScroller.position.maxScrollExtent);
          }
        });
        process.stderr.transform(utf8.decoder).forEach((element) {
          element = element.trim();
          if (element.isEmpty) return;
          textController.text +=
              "${DateFormat("hh:mm:ss").format(DateTime.now())} stderr: $element\n";
          if (textScroller.hasClients) {
            textScroller.jumpTo(textScroller.position.maxScrollExtent);
          }
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
