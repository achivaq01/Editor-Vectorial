import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class ItemShape extends StatefulWidget {
  final int shapeIndex;

  const ItemShape({Key? key, required this.shapeIndex}) : super(key: key);

  @override
  _ItemShapeState createState() => _ItemShapeState();
}

class _ItemShapeState extends State<ItemShape> {

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    bool isSelected = appData.shapeSelected == widget.shapeIndex;

    return GestureDetector(
      onTapDown: (context) {
        setState(() {
          if (appData.shapeSelected == widget.shapeIndex) {
            appData.setShapeSelected(-1);
          } else {
            appData.setShapeSelected(widget.shapeIndex);
          }
        });
      },
      onTapUp: (context) {

      },
      child: Card(
        elevation: 10,
        color: isSelected ? Colors.blueAccent : CDKTheme.white,
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
              Text('Shape ${widget.shapeIndex}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: appData.shapesList[widget.shapeIndex].strokeColor,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Brush Size: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(appData.shapesList[widget.shapeIndex].strokeWidth.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}