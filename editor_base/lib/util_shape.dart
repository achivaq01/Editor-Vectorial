import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:xml/xml.dart' as xml;

class Shape {
  Offset initialPosition = const Offset(0, 0);
  Offset finalPosition = const Offset(0, 0);
  Offset position = const Offset(0, 0);

  double width = 0;
  double height = 0;
  double left = 0;
  double top = 0;

  double rx = 0;
  double ry = 0;
  double cx = 0;
  double cy = 0;

  List<Offset> vertices = [];

  double strokeWidth = 1;
  Color strokeColor = const Color(0xFF000000);
  Color fillColor = CDKTheme.transparent;

  bool closed = false;
  bool isEllipsed = false;
  bool isPath = false;
  bool isLine = false;
  bool isMultiline = false;
  bool isRectangle = false;
  bool isEllipsis = false;

  Shape();

  void setInitialPosition(Offset newInitialPosition) {
    initialPosition = newInitialPosition;
  }

  void setFinalPosition(Offset newFinalPosition) {
    finalPosition = newFinalPosition;
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
  }

  void setFillColor(Color color) {
    fillColor = color;
  }

  void setStrokeColor(Color color) {
    strokeColor = color;
  }

  void setClosed() {
    closed = !closed;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  String colorToRgba(Color color) {
    return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha / 255})';
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'shape_drawing',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': strokeWidth,
        'strokeColor': strokeColor.value,
        'fillColor': fillColor.value,
        'isEllipsed': isEllipsed,
        'isPath': isPath,
        'isLine': isLine,
        'isMultiline': isMultiline,
        'isRectangle': isRectangle,
        'isEllipsis': isEllipsis
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
      ..setStrokeColor(Color(objectMap['strokeColor']))
      ..setFillColor(Color(objectMap['fillColor']))
      ..isEllipsed = (objectMap['isEllipsed']);

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }

  xml.XmlElement toSvgElement() {
    xml.XmlElement? xmlShape;
    xmlShape ??= xml.XmlElement(xml.XmlName('placeholder'), []);

    if (isPath) {
      StringBuffer pathData = StringBuffer();
      List<Offset> pathVertices =
          vertices.map((vertex) => vertex + position).toList();

      pathData.write('M${pathVertices.first.dx} ${pathVertices.first.dy} ');
      for (int i = 1; i < pathVertices.length; i++) {
        pathData.write('L${pathVertices[i].dx} ${pathVertices[i].dy} ');
      }
      if (closed) {
        pathData.write('Z');
      }

      xmlShape = xml.XmlElement(
        xml.XmlName('path'),
        [
          xml.XmlAttribute(xml.XmlName('d'), pathData.toString()),
          xml.XmlAttribute(xml.XmlName('style'),
              'fill:${colorToRgba(fillColor)};stroke:${colorToRgba(strokeColor)};stroke-width:$strokeWidth'),
        ],
      );
    } else if (isLine) {
      xmlShape = xml.XmlElement(
        xml.XmlName('line'),
        [
          xml.XmlAttribute(
              xml.XmlName('x1'), (initialPosition.dx + position.dx).toString()),
          xml.XmlAttribute(
              xml.XmlName('y1'), (initialPosition.dy + position.dy).toString()),
          xml.XmlAttribute(
              xml.XmlName('x2'), (finalPosition.dx + position.dx).toString()),
          xml.XmlAttribute(
              xml.XmlName('y2'), (finalPosition.dy + position.dy).toString()),
          xml.XmlAttribute(xml.XmlName('style'),
              'stroke:${colorToRgba(strokeColor)};stroke-width:$strokeWidth'),
        ],
      );
    } else if (isMultiline) {
      xmlShape = xml.XmlElement(
        xml.XmlName('polyline'),
        [
          xml.XmlAttribute(
              xml.XmlName('points'),
              vertices
                  .map((vertex) =>
                      '${vertex.dx + position.dx},${vertex.dy + position.dy}')
                  .join(' ')),
          xml.XmlAttribute(xml.XmlName('style'),
              'fill:${colorToRgba(fillColor)};stroke:${colorToRgba(strokeColor)};stroke-width:$strokeWidth'),
        ],
      );
    } else if (isRectangle) {
      xmlShape = xml.XmlElement(
        xml.XmlName('rect'),
        [
          xml.XmlAttribute(xml.XmlName('width'), width.toString()),
          xml.XmlAttribute(xml.XmlName('height'), height.toString()),
          xml.XmlAttribute(xml.XmlName('x'), (left + position.dx).toString()),
          xml.XmlAttribute(xml.XmlName('y'), (top + position.dy).toString()),
          xml.XmlAttribute(xml.XmlName('style'),
              'fill:${colorToRgba(fillColor)};stroke-width:$strokeWidth;stroke:${colorToRgba(strokeColor)}'),
        ],
      );
    } else if (isEllipsis) {
      xmlShape = xml.XmlElement(
        xml.XmlName('ellipse'),
        [
          xml.XmlAttribute(xml.XmlName('rx'), rx.toString()),
          xml.XmlAttribute(xml.XmlName('ry'), ry.toString()),
          xml.XmlAttribute(xml.XmlName('cx'), (cx + position.dx).toString()),
          xml.XmlAttribute(xml.XmlName('cy'), (cy + position.dy).toString()),
          xml.XmlAttribute(xml.XmlName('style'),
              'fill:${colorToRgba(fillColor)};stroke:${colorToRgba(strokeColor)};stroke-width:$strokeWidth'),
        ],
      );
    }

    return xmlShape;
  }
}
