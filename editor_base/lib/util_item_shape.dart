import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class ItemShape extends StatelessWidget {
  final int shapeIndex;
  bool isSelected = false;

  ItemShape({required this.shapeIndex});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return GestureDetector(
      onTapDown: (context) {
        appData.shapesList[shapeIndex].setIsSelected(true);
        print("tapping " + shapeIndex.toString());
      },
      onTapUp: (context) {

      },
      child: Card(
          elevation: 10,
          color: Color.fromARGB(255, 240, 240, 240),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shape ' + shapeIndex.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: appData.shapesList[shapeIndex].brushColor,
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Brush Size: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(appData.shapesList[shapeIndex].brushSize.toString()),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}
