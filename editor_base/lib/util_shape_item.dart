import 'dart:math';

import 'package:editor_base/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';
import 'layout_design_painter.dart';

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
    CustomPainter painter = SidebarShapePainter(appData.shapesList[widget.shapeIndex]);
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
        child: CustomPaint(
          painter: painter,
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
        )
      ),
    );
  }
}


class SidebarShapePainter extends CustomPainter {
  final Shape shape;

  SidebarShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    // Defineix els límits de dibuix del canvas
    Rect visibleRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(visibleRect);

    // Calcula les dimensions màximes del polígon
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (final vertex in shape.vertices) {
      double vertexX = shape.position.dx + vertex.dx;
      double vertexY = shape.position.dy + vertex.dy;
      minX = min(minX, vertexX);
      minY = min(minY, vertexY);
      maxX = max(maxX, vertexX);
      maxY = max(maxY, vertexY);
    }

    // Dimensions màximes del polígon
    double width = maxX - minX;
    double height = maxY - minY;
// Centre del polígon
    double centerX = minX - width / 8;
    double centerY = minY + height / 2;

    // Escala per ajustar el polígon dins del canvas
    double scaleX = size.width / width * 0.8;
    double scaleY = size.height / height * 0.8;
    double scale = min(scaleX, scaleY);

    // Centre del canvas
    double canvasCenterX = size.width / 2;
    double canvasCenterY = size.height / 2;

    double tX = canvasCenterX - centerX * scale;
    double tY = canvasCenterY - centerY * scale;

    canvas.translate(tX, tY);
    canvas.scale(scale);

    // Dibuixa el polígon
    LayoutDesignPainter.paintShape(canvas, shape);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
