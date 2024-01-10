import 'dart:io' show Platform;
import 'package:editor_base/app_data_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_data.dart';
import 'layout.dart';

void main() async {
  // For Linux, macOS and Windows, initialize WindowManager
  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }

  AppData appData = AppData();

  runApp(Focus(
    onKey: (FocusNode node, RawKeyEvent event) {
      bool isControlPressed = (Platform.isMacOS && event.isMetaPressed) ||
          (Platform.isLinux && event.isControlPressed) ||
          (Platform.isWindows && event.isControlPressed);
      bool isShiftPressed = event.isShiftPressed;
      bool isZPressed = event.logicalKey == LogicalKeyboardKey.keyZ;
      bool isSuprPressed = event.logicalKey == LogicalKeyboardKey.delete;

      if (event is RawKeyDownEvent) {
        if (isControlPressed && isZPressed && !isShiftPressed) {
          appData.actionManager.undo();
          return KeyEventResult.handled;
        } else if (isControlPressed && isShiftPressed && isZPressed) {
          appData.actionManager.redo();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = true;
        }
        if (isControlPressed && isSuprPressed && appData.shapeSelected >= 0 && appData.shapesList.isNotEmpty) {
          appData.actionManager.register(ActionDeleteSelectedShape(appData, appData.shapesList[appData.shapeSelected]));
          appData.shapeSelected = -1;
        }
      } else if (event is RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = false;
        }
      }
      return KeyEventResult.ignored;
    },
    child: ChangeNotifierProvider(
      create: (context) => appData,
      child: const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor:
            "systemBlue", // systemBlue, systemPurple, systemPink, systemRed, systemOrange, systemYellow, systemGreen, systemGray
        child: Layout(),
      ),
    ),
  ));
}

// Show the window when it's ready
void showWindow(_) async {
  const size = Size(800.0, 600.0);
  windowManager.setSize(size);
  windowManager.setMinimumSize(size);
  await windowManager.setTitle('Vector Editor');
}
