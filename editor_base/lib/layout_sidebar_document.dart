import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'util_button_color.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({Key? key});

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
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
        appData.setBackgroundColor(_valueColorNotifier.value);
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
            color: appData.backgroundColor,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                appData.setBackgroundColorTemp(color);
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _preloadedColorPicker = _buildPreloadedColorPicker();
    AppData appData = Provider.of<AppData>(context);

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
              Text("Document properties:", style: fontBold),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Width:", style: font)),
                const SizedBox(width: 4),
                Container(
                    alignment: Alignment.centerLeft,
                    width: 80,
                    child: CDKFieldNumeric(
                      value: appData.docSize.width,
                      min: 1,
                      max: 2500,
                      units: "px",
                      increment: 100,
                      decimals: 0,
                      onValueChanged: (value) {
                        appData.setDocWidth(value);
                      },
                    )),
              ]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Height:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.docSize.height,
                        min: 1,
                        max: 2500,
                        units: "px",
                        increment: 100,
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setDocHeight(value);
                        },
                      ))
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text("       Background color:", style: font),
                const SizedBox(width: 4),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: ValueListenableBuilder<Color>(
                        valueListenable: _valueColorNotifier,
                        builder: (context, value, child) {
                          return UtilButtonColor(
                              key: _anchorColorButton,
                              color: _valueColorNotifier.value,
                              containerColor: appData.backgroundColor,
                              onPressed: () {
                                _showPopoverColor(context, _anchorColorButton);
                              });
                        })),
              ]),
              const SizedBox(height: 16),
              CDKButton(
                onPressed: () {
                  appData.loadFile();
                },
                child: const Text('Load file'),
              ),
              CDKButton(
                onPressed: () {
                  appData.saveFile();
                },
                child: Text(appData.saveFilePath != null ? 'Save' : 'Save as'),
              ),
              CDKButton(
                onPressed: () {
                  appData.exportFile();
                },
                child: const Text('Export as SVG'),
              )
            ],
          );
        },
      ),
    );
  }
}
