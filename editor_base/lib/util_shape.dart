import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  Color brushColor = Colors.black;
  double brushSize = 20;
  double rotation = 0;
  bool isSelected = false;
  List<Offset> points = [];
/* USE THIS CODE TO FIND THE MIN AND MAX VALUES TO DRAW THE SELECT RECTANGLE
Offset minOffset = points.reduce((min, point) =>
      Offset(min.dx < point.dx ? min.dx : point.dx, min.dy < point.dy ? min.dy : point.dy));

  Offset maxOffset = points.reduce((max, point) =>
      Offset(max.dx > point.dx ? max.dx : point.dx, max.dy > point.dy ? max.dy : point.dy));
 */


  Shape();

  Shape.custom(double stroke, Color color) {
    this.brushSize = stroke;
    this.brushColor = color;
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void setIsSelected(bool isSelected) {
    this.isSelected = isSelected;
  }

  void setScale(Size newScale) {
    scale = newScale;
  }

  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  void addPoint(Offset point) {
    points.add(Offset(point.dx, point.dy));
  }

  void setBrushColor(Color color) {
    brushColor = color;
  }

  void setBrushSize(double size) {
    brushSize = size;
  }

  void addRelativePoint(Offset point) {
    points.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }
}
