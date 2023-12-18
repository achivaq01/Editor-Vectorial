import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class ItemShape extends StatelessWidget {
  final int shapeIndex;
  Color cardColor = CDKTheme.white;

  ItemShape({super.key, required this.shapeIndex});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return GestureDetector(
      onTapDown: (context) {
        if (appData.shapeSelected == shapeIndex) {
          appData.setShapeSelected(-1);
          return;
        }
        appData.setShapeSelected(shapeIndex);
      },
      onTapUp: (context) {

      },
      child: Card(
          elevation: 10,
          color: CDKTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(
              color: CDKTheme.white,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shape $shapeIndex', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: appData.shapesList[shapeIndex].strokeColor,
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Brush Size: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(appData.shapesList[shapeIndex].strokeWidth.toString()),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}