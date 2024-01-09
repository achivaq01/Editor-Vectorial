import 'dart:ffi';

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
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
  ValueNotifier(const Color(0x800080FF));

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
            color: appData.shapeSelected >= 0 ? appData.shapesList[appData.shapeSelected].strokeColor : appData.newShapeColor,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                if (appData.shapeSelected >= 0 &&
                    appData.shapesList.isNotEmpty &&
                    appData.shapeSelected < appData.shapesList.length) {
                  //appData.shapesList[appData.shapeSelected].strokeColor = color;
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
                    value: appData.shapeSelected >= 0 && appData.shapesList.isNotEmpty ? appData.shapesList[appData.shapeSelected].strokeWidth : appData.newShape.strokeWidth,
                    min: 0.01,
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
                          key: _anchorColorButton,
                          color: _valueColorNotifier.value,
                          containerColor: appData.shapeSelected >= 0 && appData.shapesList.isNotEmpty
                              ? appData.shapesList[appData.shapeSelected].strokeColor
                              : appData.newShapeColor,
                          onPressed: () {
                            _showPopoverColor(
                                context, _anchorColorButton);
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
