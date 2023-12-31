// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
  void erase();
}

// Gestiona la llista d'accions per poder desfer i refer
class ActionManager {
  List<Action> actions = [];
  int currentIndex = -1;

  void register(Action action) {
    // Elimina les accions que estan després de l'índex actual
    if (currentIndex < actions.length - 1) {
      actions = actions.sublist(0, currentIndex + 1);
    }
    actions.add(action);
    currentIndex++;
    action.redo();
  }

  void undo() {
    if (currentIndex >= 0) {
      actions[currentIndex].undo();
      currentIndex--;
    }
  }

  void redo() {
    if (currentIndex < actions.length - 1) {
      currentIndex++;
      actions[currentIndex].redo();
    }
  }

  void erase(AppData appData) {
    if (appData.shapeSelected >= 0) {
      appData.shapesList.removeAt(appData.shapeSelected);
      appData.shapeSelected = -1;
      appData.forceNotifyListeners();
      // appData.notifyListeners();
    }
  }
}

class ActionSetDocWidth implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocWidth(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(value, appData.docSize.height);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }

  @override
  void erase() {}
}

class ActionSetDocHeight implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocHeight(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(appData.docSize.width, value);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }

  @override
  void erase() {}
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    /*
    if (appData.shapesList[appData.shapeSelected] == newShape) {
      appData.shapeSelected = -1;
    }
    */
    appData.shapeSelected = -1;
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void erase() {
    if (appData.shapesList.isEmpty) {
      return;
    }
    if (appData.shapeSelected >= 0) {
      appData.shapesList.remove(appData.shapesList[appData.shapeSelected]);
      appData.forceNotifyListeners();
    }
  }
}

class ActionSetDocColor implements Action {
  final AppData appData;
  final Color previousColor;
  final Color newColor;

  ActionSetDocColor(this.appData, this.previousColor, this.newColor);

  @override
  void redo() {
    appData.backgroundColor = newColor;
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    appData.backgroundColor = previousColor;
    appData.forceNotifyListeners();
  }

  @override
  void erase() {}
}

class ActionMoveShape implements Action {
  final AppData appData;
  final Shape movedShape;
  final Offset previousPosition;
  final Offset newPosition;

  ActionMoveShape(
      this.appData, this.movedShape, this.previousPosition, this.newPosition);

  @override
  void undo() {
    movedShape.position = previousPosition;
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    movedShape.position = newPosition;
    appData.forceNotifyListeners();
  }

  @override
  void erase() {}
}
