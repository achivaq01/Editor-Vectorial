import 'package:flutter/cupertino.dart';

class Shape {
  Offset position = const Offset(0, 0);
  List<Offset> vertices = [];
  double strokeWidth = 1;
  Color strokeColor = const Color(0xFF000000);
  Color fillColor = const Color(0xFF000000);
  bool closed = false;
  bool isEllipsed = false;

  Shape();

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'shape_drawing',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': strokeWidth,
        'strokeColor': strokeColor.value,
      }
    };
  }

  static Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_drawing') {
      throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = Shape()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setStrokeColor(Color(objectMap['strokeColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }

  setStrokeColor(Color color) {
    strokeColor = color;
  }

  void setClosed() {
    closed = !closed;
  }

  bool isClosed() {
    return closed;
  }
}
