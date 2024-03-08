import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';
import 'package:xml/xml.dart' as xml;

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape();
  List<Shape> shapesList = [];
  int shapeSelected = -1;
  int shapeSelectedPrevious = -1;
  double newShapeStrokeWidth = 1;
  Color newShapeColor = Colors.black;
  Color newFillColor = Colors.transparent;
  Color backgroundColor = Colors.white;
  Color? backgroundColorTemp;
  Color? shapeSelectedColorTemp;
  Color? shapeSelectedFillColorTemp;
  Offset? shapeSelectedPositionTemp;
  Offset mouseToPolygonDifference = Offset.zero;
  String? saveFilePath;
  String? exportFilePath;

  bool readyExample = false;
  late dynamic dataExample;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

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
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void setShapeSelected(int index) {
    shapeSelected = index;
    notifyListeners();
  }

  Future<void> selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    shapeSelectedPrevious = shapeSelected;
    shapeSelected = -1;
    setShapeSelected(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  void addNewShape(Offset position) {
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      double strokeWidthConfig = newShape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = Shape();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setSelectedShapeStrokeWidth(double value) {
    actionManager.register(ActionModifyShapeStrokeWidth(
        this, value, shapesList[shapeSelected].strokeWidth, shapeSelected));
    notifyListeners();
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void setNewShapeColor(Color color) {
    newShapeColor = color;
    notifyListeners();
  }

  void setNewFillColor(Color color) {
    newFillColor = color;
    notifyListeners();
  }

  void setShapeSelectedColorTemp(Color color) {
    shapeSelectedColorTemp ??= shapesList[shapeSelected].strokeColor;
    shapesList[shapeSelected].strokeColor = color;
    notifyListeners();
  }

  void setShapeSelectedFillColorTemp(Color color) {
    shapeSelectedFillColorTemp ??= shapesList[shapeSelected].fillColor;
    shapesList[shapeSelected].fillColor = color;
    notifyListeners();
  }

  void setShapeSelectedFillColor(Color color) {
    actionManager.register(ActionModifyFillColor(
        this, color, shapeSelectedFillColorTemp!, shapeSelected));
    shapeSelectedFillColorTemp = null;
    notifyListeners();
  }

  void setShapeSelectedColor(Color color) {
    actionManager.register(ActionModifyShapeColor(
        this, color, shapeSelectedColorTemp!, shapeSelected));
    shapeSelectedColorTemp = null;
    notifyListeners();
  }

  void setBackgroundColorTemp(Color color) {
    backgroundColorTemp ??= backgroundColor;
    backgroundColor = color;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    actionManager.register(
        ActionChangeBackgroundColor(this, color, backgroundColorTemp));
    backgroundColorTemp = null;
    notifyListeners();
  }

  void setShapeSelectedPosition(Offset offset) {
    if (shapeSelectedPositionTemp == null) {
      return;
    }
    actionManager.register(ActionChangeShapeSelectedPosition(
        this, offset, shapeSelectedPositionTemp!, shapeSelected));
    shapesList[shapeSelected].position = offset;
    notifyListeners();
  }

  void setShapeSelectedPositionTemp(Offset offset) {
    shapeSelectedPositionTemp ??= shapesList[shapeSelected].position;
    shapesList[shapeSelected].position = offset;
    notifyListeners();
  }

  void addShapeFromClipboardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    Map<String, dynamic>? parsedJson = jsonDecode(data!.text!.toString());
    if (parsedJson == null || !parsedJson.containsKey('type')) {
      return;
    }
    if (parsedJson['type'] != 'shape_drawing') {
      return;
    }
    actionManager.register(ActionAddNewShape(this, Shape.fromMap(parsedJson)));
    notifyListeners();
  }

  Map<String, dynamic> documentToMap() {
    return {
      'document_height': docSize.height,
      'document_width': docSize.width,
      'document_color': backgroundColor.value
    };
  }

  Future<void> saveFile() async {
    saveFilePath ?? await pickSaveFile();

    File file = File(saveFilePath!);
    List<Map<String, dynamic>> list =
        shapesList.map((shape) => shape.toMap()).toList();
    Map<String, dynamic> data = {'document': documentToMap(), 'shapes': list};
    String jsonString = const JsonEncoder.withIndent(" ").convert(data);
    await file.writeAsString(jsonString,
        mode: FileMode.writeOnly, flush: true, encoding: utf8);
  }

  Future<void> pickSaveFile() async {
    saveFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'output-file.json',
    );
  }

  Future<void> pickExportFile() async {
    exportFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'output-file.svg',
    );
  }

  Future<void> pickLoadFile() async {
    FilePicker picker = FilePicker.platform;
    FilePickerResult? result =
        await picker.pickFiles(dialogTitle: 'file to load');
    saveFilePath = result!.files[0].path;
  }

  Future<void> loadFile() async {
    await pickLoadFile();

    File file = File(saveFilePath!);
    Map<String, dynamic> data = jsonDecode(file.readAsStringSync());

    if (!data.containsKey('document')) {
      return;
    }

    docSize = Size(data['document']['document_width'],
        data['document']['document_height']);

    if (!data.containsKey('shapes')) {
      return;
    }

    List<Map<String, dynamic>> shapesData =
        List<Map<String, dynamic>>.from(data['shapes']);
    shapesList = [];

    for (Map<String, dynamic> shapeData in shapesData) {
      Shape shape = Shape.fromMap(shapeData);
      shapesList.add(shape);
    }

    notifyListeners();
  }

  Future<void> exportFile() async {
    exportFilePath ?? await pickExportFile();

    File file = File(exportFilePath!);

    var document = xml.XmlDocument(
      [
        xml.XmlElement(
          xml.XmlName('svg'),
          [
            xml.XmlAttribute(xml.XmlName('width'), docSize.width.toString()),
            xml.XmlAttribute(xml.XmlName('height'), docSize.height.toString()),
            xml.XmlAttribute(
                xml.XmlName('xmlns'), 'http://www.w3.org/2000/svg'),
            xml.XmlAttribute(xml.XmlName('version'), '1.1'),
            xml.XmlAttribute(
              xml.XmlName('style'),
              'background-color: ${'#${backgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'}',
            ),
          ],
          shapesList.map((shape) => shape.toSvgElement()).toList(),
        ),
      ],
    );

    await file.writeAsString(document.toXmlString(pretty: true));
  }
}
