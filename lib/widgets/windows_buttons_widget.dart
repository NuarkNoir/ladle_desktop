import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      // ? For some reasong {WindowsCaption} is not available
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MinimizeWindowButton(),
          CloseWindowButton(),
        ],
      ),
    );
  }
}
