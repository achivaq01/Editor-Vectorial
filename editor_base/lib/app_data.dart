import 'package:flutter/material.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape();
  List<Shape> shapesList = [];

  bool readyExample = false;
  late dynamic dataExample;

  Color shapeColor = Colors.black;
  double brushSize = 1;

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    docSize = Size(value, docSize.height);
    notifyListeners();
  }

  void setDocHeight(double value) {
    docSize = Size(docSize.width, value);
    notifyListeners();
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void addNewShape(Offset position) {
    newShape = Shape();
    newShape.setPosition(position);
    newShape.addPoint(Offset(0, 0));
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.points.length >= 2) {
      shapesList.add(newShape);
      newShape = Shape();
      notifyListeners();
    }
  }
}
