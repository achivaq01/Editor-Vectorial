import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';
import 'util_custom_scroll_vertical.dart';
import 'util_custom_scroll_horizontal.dart';

class LayoutDesign extends StatefulWidget {
  const LayoutDesign({super.key});

  @override
  LayoutDesignState createState() => LayoutDesignState();
}

class LayoutDesignState extends State<LayoutDesign> {
  final GlobalKey<UtilCustomScrollHorizontalState> _keyScrollX = GlobalKey();
  final GlobalKey<UtilCustomScrollVerticalState> _keyScrollY = GlobalKey();
  Offset _scrollCenter = const Offset(0, 0);
  bool _isMouseButtonPressed = false;
  late Offset _dragStartPosition;
  late Offset _dragStartOffset;
  final FocusNode _focusNode = FocusNode();
  Offset _rectStartPosition = const Offset(0, 0);
  Offset _ellipseStartPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    initShaders();
  }

  Future<void> initShaders() async {
    await LayoutDesignPainter.initShaders();
    setState(() {});
  }

  // Retorna l'area de scroll del document
  Size _getScrollArea(AppData appData) {
    return Size(((appData.docSize.width * appData.zoom) / 100) + 50,
        ((appData.docSize.height * appData.zoom) / 100) + 50);
    // Force 50 pixels padding (to show 25 pixels rulers)
  }

  // Retorna el desplacament del document respecte el centre de la pantalla
  Offset _getDisplacement(Size scrollArea, BoxConstraints constraints) {
    return Offset(((scrollArea.width - constraints.maxWidth) / 2),
        ((scrollArea.height - constraints.maxHeight) / 2));
  }

  // Retorna la posició x,y al document, respecte on s'ha fet click
  Offset _getDocPosition(Offset position, double zoom,
      BoxConstraints constraints, Size docSize, Offset center) {
    double scale = zoom / 100;
    double translateX =
        (constraints.maxWidth / (2 * scale)) - (docSize.width / 2) - center.dx;
    double translateY = (constraints.maxHeight / (2 * scale)) -
        (docSize.height / 2) -
        center.dy;
    double originalX = (position.dx / scale) - translateX;
    double originalY = (position.dy / scale) - translateY;

    return Offset(originalX, originalY);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      AppData appData = Provider.of<AppData>(context);
      CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

      Size scrollArea = _getScrollArea(appData);
      Offset scrollDisplacement = _getDisplacement(scrollArea, constraints);

      double tmpScrollX = _scrollCenter.dx;
      double tmpScrollY = _scrollCenter.dy;
      if (_keyScrollX.currentState != null) {
        if (scrollArea.width < constraints.maxWidth) {
          _keyScrollX.currentState!.setOffset(0);
        } else {
          tmpScrollX = _keyScrollX.currentState!.getOffset() *
              (scrollDisplacement.dx * 100 / appData.zoom);
        }
      }

      if (_keyScrollY.currentState != null) {
        if (scrollArea.height < constraints.maxHeight) {
          _keyScrollY.currentState!.setOffset(0);
        } else {
          tmpScrollY = _keyScrollY.currentState!.getOffset() *
              (scrollDisplacement.dy * 100 / appData.zoom);
        }
      }

      _scrollCenter = Offset(tmpScrollX, tmpScrollY);

      // Choose cursor
      MouseCursor cursorShown = MouseCursor.defer;
      if (appData.toolSelected == "pointer_shapes") {
        cursorShown = SystemMouseCursors.basic;
      } else if (appData.toolSelected == "view_grab") {
        if (_isMouseButtonPressed) {
          cursorShown = SystemMouseCursors.grabbing;
        } else {
          cursorShown = SystemMouseCursors.grab;
        }
      } else {
        cursorShown = SystemMouseCursors.precise;
      }

      return Stack(
        children: [
          GestureDetector(
              onDoubleTap: () {
                if (appData.toolSelected == "shape_multiline" &&
                    appData.newShape.vertices.length > 1) {
                  Offset firstTap = appData.newShape.vertices.first;
                  Offset lastTap = appData.newShape.vertices.last;
                  if (firstTap != lastTap) {
                    appData.newShape.isMultiline = true;
                    appData.addNewShapeToShapesList();
                  }
                }
              },
              onPanEnd: (details) {
                _keyScrollX.currentState!.startInertiaAnimation();
                _keyScrollY.currentState!.startInertiaAnimation();
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (!_isMouseButtonPressed) {
                  if (appData.isAltOptionKeyPressed) {
                    appData.setZoom(appData.zoom + details.delta.dy);
                  } else {
                    if (details.delta.dx != 0) {
                      _keyScrollX.currentState!
                          .setTrackpadDelta(details.delta.dx);
                    }
                    if (details.delta.dy != 0) {
                      _keyScrollY.currentState!
                          .setTrackpadDelta(details.delta.dy);
                    }
                  }
                }
              },
              child: MouseRegion(
                  cursor: cursorShown,
                  child: Listener(
                      onPointerDown: (event) async {
                        _focusNode.requestFocus();
                        _isMouseButtonPressed = true;
                        Size docSize =
                            Size(appData.docSize.width, appData.docSize.height);

                        // Calculate the initial difference between mouse and polygon position
                        Offset docPosition = _getDocPosition(
                          event.localPosition,
                          appData.zoom,
                          constraints,
                          docSize,
                          _scrollCenter,
                        );

                        if (appData.toolSelected == "pointer_shapes") {
                          await appData.selectShapeAtPosition(docPosition,
                              event.localPosition, constraints, _scrollCenter);
                          if (appData.shapeSelected != -1) {
                            _dragStartPosition = appData
                                .shapesList[appData.shapeSelected].position;
                            _dragStartOffset = docPosition - _dragStartPosition;
                          }
                        }

                        if (appData.toolSelected == "shape_drawing") {
                          appData.addNewShape(docPosition);
                          appData.shapeSelected - 1;
                        }

                        if (appData.toolSelected == "shape_line") {
                          appData.shapeSelected = -1;
                          appData.newShape.addRelativePoint(docPosition);
                          appData.newShape.setInitialPosition(docPosition);
                        }

                        if (appData.toolSelected == "shape_multiline") {
                          appData.addRelativePointToNewShape(docPosition);
                        }

                        if (appData.toolSelected == "shape_rectangle") {
                          _rectStartPosition = docPosition;
                        }

                        if (appData.toolSelected == "shape_ellipsis") {
                          _ellipseStartPosition = docPosition;
                          appData.addRelativePointToNewShape(
                              _ellipseStartPosition);
                        }

                        setState(() {});
                      },
                      onPointerMove: (event) {
                        Size docSize =
                            Size(appData.docSize.width, appData.docSize.height);
                        Offset docPosition = _getDocPosition(
                            event.localPosition,
                            appData.zoom,
                            constraints,
                            docSize,
                            _scrollCenter);

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "shape_drawing") {
                          appData.addRelativePointToNewShape(docPosition);
                        }

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "view_grab") {
                          if (event.delta.dx != 0) {
                            _keyScrollX.currentState!
                                .setTrackpadDelta(event.delta.dx);
                          }
                          if (event.delta.dy != 0) {
                            _keyScrollY.currentState!
                                .setTrackpadDelta(event.delta.dy);
                          }
                        }

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "shape_line") {
                          if (appData.newShape.vertices.length < 2) {
                            appData.addRelativePointToNewShape(docPosition);
                          } else {
                            appData.newShape.vertices.last = docPosition;
                          }
                          appData.newShape.setFinalPosition(docPosition);
                          setState(() {});
                        }

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "shape_multiline") {
                          if (appData.newShape.vertices.length < 2) {
                            appData.addRelativePointToNewShape(docPosition);
                          } else {
                            appData.newShape.vertices.last = docPosition;
                          }
                          setState(() {});
                        }

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "shape_rectangle") {
                          appData.newShape = Shape();

                          Offset startPoint = _rectStartPosition;
                          Offset endPoint = docPosition;

                          double left = startPoint.dx < endPoint.dx
                              ? startPoint.dx
                              : endPoint.dx;
                          double top = startPoint.dy < endPoint.dy
                              ? startPoint.dy
                              : endPoint.dy;
                          double right = startPoint.dx > endPoint.dx
                              ? startPoint.dx
                              : endPoint.dx;
                          double bottom = startPoint.dy > endPoint.dy
                              ? startPoint.dy
                              : endPoint.dy;

                          appData.newShape.width =
                              (endPoint.dx - startPoint.dx).abs();
                          appData.newShape.height =
                              (endPoint.dy - startPoint.dy).abs();
                          appData.newShape.left = left;
                          appData.newShape.top = top;

                          appData.addRelativePointToNewShape(Offset(left, top));
                          appData
                              .addRelativePointToNewShape(Offset(right, top));
                          appData.addRelativePointToNewShape(
                              Offset(right, bottom));
                          appData
                              .addRelativePointToNewShape(Offset(left, bottom));
                          appData.addRelativePointToNewShape(Offset(left, top));

                          setState(() {});
                        }

                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "shape_ellipsis") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);

                          Offset ellipsePosition = _getDocPosition(
                            event.localPosition,
                            appData.zoom,
                            constraints,
                            docSize,
                            _scrollCenter,
                          );

                          appData.newShape.isEllipsed = true;

                          if (appData.newShape.vertices.length > 1) {
                            appData.newShape.vertices[1] = ellipsePosition;
                          } else {
                            appData.addRelativePointToNewShape(ellipsePosition);
                          }

                          setState(() {});
                        }

                        if (appData.toolSelected == "pointer_shapes" &&
                            appData.shapeSelected != -1) {
                          Offset newShapePosition =
                              docPosition - _dragStartOffset;
                          appData
                              .setShapeSelectedPositionTemp(newShapePosition);
                        }
                      },
                      onPointerUp: (event) {
                        _isMouseButtonPressed = false;

                        if (appData.toolSelected == "shape_drawing") {
                          appData.addNewShapeToShapesList();
                        }

                        if (appData.toolSelected == "shape_line") {
                          appData.newShape.isLine = true;
                          appData.addNewShapeToShapesList();
                        }

                        if (appData.toolSelected == "shape_rectangle") {
                          appData.newShape.isRectangle = true;
                          appData.addNewShapeToShapesList();
                        }

                        if (appData.toolSelected == "shape_ellipsis") {
                          appData.newShape.isEllipsis = true;
                          appData.addNewShapeToShapesList();
                        }

                        if (appData.toolSelected == "pointer_shapes" &&
                            appData.shapeSelected != -1) {
                          appData.setShapeSelectedPosition(appData
                              .shapesList[appData.shapeSelected].position);
                        }

                        setState(() {});
                      },
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          if (!_isMouseButtonPressed) {
                            if (appData.isAltOptionKeyPressed) {
                              appData.setZoom(
                                  appData.zoom + pointerSignal.scrollDelta.dy);
                            } else {
                              _keyScrollX.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dx);
                              _keyScrollY.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dy);
                            }
                          }
                        }
                      },
                      child: CustomPaint(
                        painter: LayoutDesignPainter(
                          appData: appData,
                          theme: theme,
                          centerX: _scrollCenter.dx,
                          centerY: _scrollCenter.dy,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      )))),
          UtilCustomScrollHorizontal(
            key: _keyScrollX,
            size: constraints.maxWidth,
            contentSize: scrollArea.width,
            onChanged: (value) {
              setState(() {});
            },
          ),
          UtilCustomScrollVertical(
            key: _keyScrollY,
            size: constraints.maxHeight,
            contentSize: scrollArea.height,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      );
    });
  }
}
