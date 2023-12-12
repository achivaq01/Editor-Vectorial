import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme_notifier.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class itemShape extends StatelessWidget {
  int shapeIndex = 1;
  double brushSize = 1.0;
  Color color = Colors.black;

  itemShape.custom(int index) {
    shapeIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shape ' + shapeIndex.toString()),
          SizedBox(
            height: 20,
            width: 20,
            child: ColoredBox(
              color: appData.shapesList[shapeIndex].brushColor,
            ),
          ),
          Text('Brush size: ' + appData.shapesList[shapeIndex].brushSize.toString())
        ],
      ),
    );
  }
}
