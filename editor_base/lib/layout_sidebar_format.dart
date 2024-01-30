import 'package:editor_base/util_button_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatefulWidget {
  const LayoutSidebarFormat({super.key});

  @override
  LayoutSidebarFormatState createState() => LayoutSidebarFormatState();
}

class LayoutSidebarFormatState extends State<LayoutSidebarFormat> {
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorStrokeColorButton = GlobalKey();
  final GlobalKey<CDKDialogPopoverState> _anchorFillColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(const Color(0x800080FF));
  final ValueNotifier<bool> _valueShapeClosedNotifier = ValueNotifier(false);

  _showPopoverColor(BuildContext context, GlobalKey anchorKey) {
    AppData appData = Provider.of<AppData>(context, listen: false);
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
    if (anchorKey.currentContext == null) {
      // ignore: avoid_print
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
      key: key,
      context: context,
      anchorKey: anchorKey,
      isAnimated: true,
      isTranslucent: false,
      onHide: () {
        if (appData.shapeSelected >= 0) {
          appData.setShapeSelectedColor(_valueColorNotifier.value);
        }
      },
      child: _preloadedColorPicker,
    );
  }

  Widget _buildPreloadedColorPicker() {
    AppData appData = Provider.of<AppData>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          return CDKPickerColor(
            color: appData.shapeSelected >= 0
                ? appData.shapesList[appData.shapeSelected].strokeColor
                : appData.newShapeColor,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                if (appData.shapeSelected >= 0 &&
                    appData.shapesList.isNotEmpty &&
                    appData.shapeSelected < appData.shapesList.length) {
                  appData.setShapeSelectedColorTemp(color);
                }
                appData.setNewShapeColor(color);
                //appData.setNewShapeColor(color);
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    _preloadedColorPicker = _buildPreloadedColorPicker();

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Coordinates", style: fontBold),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: labelsWidth,
                  child: Text("Offset X: ", style: font),
                ),
                const SizedBox(width: 4),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 80,
                  child: CDKFieldNumeric(
                    value: appData.shapeSelected >= 0 &&
                            appData.shapeSelected < appData.shapesList.length &&
                            appData.shapesList.isNotEmpty
                        ? appData.shapesList[appData.shapeSelected].position.dx
                        : 0,
                    units: "px",
                    increment: 0.5,
                    decimals: 2,
                    onValueChanged: (value) {
                      if (appData.shapeSelected >= 0 &&
                          appData.shapesList.isNotEmpty &&
                          appData.shapeSelected < appData.shapesList.length) {
                        appData.setShapeSelectedPosition((Offset(
                            value,
                            appData.shapesList[appData.shapeSelected].position
                                .dy)));
                      }
                    },
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: labelsWidth,
                  child: Text("Offset Y: ", style: font),
                ),
                const SizedBox(width: 4),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 80,
                  child: CDKFieldNumeric(
                    value: appData.shapeSelected >= 0 &&
                            appData.shapesList.isNotEmpty
                        ? appData.shapesList[appData.shapeSelected].position.dy
                        : 0,
                    units: "px",
                    increment: 0.5,
                    decimals: 2,
                    onValueChanged: (value) {
                      if (appData.shapeSelected >= 0 &&
                          appData.shapesList.isNotEmpty &&
                          appData.shapeSelected < appData.shapesList.length) {
                        appData.setShapeSelectedPosition((Offset(
                            appData
                                .shapesList[appData.shapeSelected].position.dx,
                            value)));
                      }
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("Stroke and fill:", style: fontBold),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: labelsWidth,
                  child: Text("Stroke width:", style: font),
                ),
                const SizedBox(width: 4),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 80,
                  child: CDKFieldNumeric(
                    value: appData.shapeSelected >= 0 &&
                            appData.shapesList.isNotEmpty &&
                            appData.shapeSelected < appData.shapesList.length
                        ? appData.shapesList[appData.shapeSelected].strokeWidth
                        : appData.newShape.strokeWidth,
                    min: 0,
                    max: 100,
                    units: "px",
                    increment: 0.5,
                    decimals: 2,
                    onValueChanged: (value) {
                      if (appData.shapeSelected >= 0 &&
                          appData.shapesList.isNotEmpty &&
                          appData.shapeSelected < appData.shapesList.length) {
                        appData.setSelectedShapeStrokeWidth(value);
                      }
                      appData.newShapeStrokeWidth = value;
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Stroke color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ValueListenableBuilder<Color>(
                      valueListenable: _valueColorNotifier,
                      builder: (context, value, child) {
                        return UtilButtonColor(
                          key: _anchorStrokeColorButton,
                          color: _valueColorNotifier.value,
                          containerColor: appData.shapeSelected >= 0 &&
                                  appData.shapesList.isNotEmpty
                              ? appData
                                  .shapesList[appData.shapeSelected].strokeColor
                              : appData.newShapeColor,
                          onPressed: () {
                            _showPopoverColor(
                                context, _anchorStrokeColorButton);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Close shape:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _valueShapeClosedNotifier,
                      builder: (context, value, child) {
                        return CDKButtonCheckBox(
                          value: appData.shapeSelected >= 0 &&
                                  appData.shapesList.isNotEmpty &&
                                  appData.shapeSelected <
                                      appData.shapesList.length
                              ? appData.shapesList[appData.shapeSelected].closed
                              : appData.newShape.closed,
                          onChanged: (value) {
                            if (appData.shapeSelected >= 0 &&
                                appData.shapesList.isNotEmpty &&
                                appData.shapeSelected <
                                    appData.shapesList.length) {
                              appData.shapesList[appData.shapeSelected]
                                  .setClosed();
                              appData.forceNotifyListeners();
                            } else {
                              appData.newShape.setClosed();
                              appData.forceNotifyListeners();
                            }
                            _valueShapeClosedNotifier.value =
                                !_valueShapeClosedNotifier.value;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Fill color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ValueListenableBuilder<Color>(
                      valueListenable: _valueColorNotifier,
                      builder: (context, value, child) {
                        return UtilButtonColor(
                          key: _anchorFillColorButton,
                          color: _valueColorNotifier.value,
                          containerColor: appData.shapeSelected >= 0 &&
                                  appData.shapesList.isNotEmpty
                              ? appData
                                  .shapesList[appData.shapeSelected].fillColor
                              : appData.newFillColor,
                          onPressed: () {
                            _showPopoverColor(context, _anchorFillColorButton);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
