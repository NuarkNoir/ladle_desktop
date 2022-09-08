import 'package:fluent_ui/fluent_ui.dart';

class AppListFragment extends StatefulWidget {
  const AppListFragment({Key? key}) : super(key: key);

  @override
  State<AppListFragment> createState() => _AppListFragmentState();
}

class _AppListFragmentState extends State<AppListFragment> {
  int currentIndex = 0;
  int tabs = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: TabView(
        currentIndex: currentIndex,
        onChanged: (index) => setState(() => currentIndex = index),
        onNewPressed: () {
          setState(() => tabs++);
        },
        tabs: List.generate(tabs, (index) {
          return Tab(
            text: Text('Tab $index'),
            closeIcon: FluentIcons.chrome_close,
          );
        }),
        bodies: List.generate(
          tabs,
          (index) => Container(
            color: index.isEven ? Colors.red : Colors.yellow,
          ),
        ),
      ),
    );
  }
}
