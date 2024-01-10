// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
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
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }

}

class ActionModifyShapeColor implements Action {
  final AppData appData;
  final Color newColor;
  final Color oldColor;
  final int shapeIndex;

  ActionModifyShapeColor(this.appData, this.newColor, this.oldColor, this.shapeIndex);

  @override
  void undo() {
    appData.shapesList[shapeIndex].strokeColor = oldColor;
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[shapeIndex].strokeColor = newColor;
    appData.forceNotifyListeners();
  }
}

class ActionModifyShapeStrokeWidth implements Action {
  final AppData appData;
  final double newStroke;
  final double oldStroke;
  final int shapeIndex;

  ActionModifyShapeStrokeWidth(this.appData, this.newStroke, this.oldStroke, this.shapeIndex);

  @override
  void undo() {
    appData.shapesList[shapeIndex].strokeWidth = oldStroke;
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[shapeIndex].strokeWidth = newStroke;
    appData.forceNotifyListeners();
  }
}

class ActionChangeBackgroundColor implements Action {
  final AppData appData;
  final Color newColor;
  final Color? oldColor;

  ActionChangeBackgroundColor(this.appData, this.newColor, this.oldColor);

  @override
  void redo() {
    appData.backgroundColor = newColor;
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    appData.backgroundColor = oldColor!;
    appData.forceNotifyListeners();
  }

}

class ActionDeleteSelectedShape implements Action {
  final AppData appData;
  final Shape shape;

  ActionDeleteSelectedShape(this.appData, this.shape);

  @override
  void redo() {
    appData.shapesList.remove(shape);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    appData.shapesList.add(shape);
    appData.forceNotifyListeners();
  }
}
