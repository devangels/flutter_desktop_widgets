import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';



enum CursorType {
  Arrow,
  Beam,
  Crosshair,
  Hand,
  ResizeX,
  ResizeY,
}


class CursorManager {

  CursorManager._();

  static CursorManager instance = CursorManager._();


  final MethodChannel _channel = MethodChannel("Cursor", JSONMethodCodec());

  void setCursor(CursorType type) {
    _channel.invokeMethod("changeCursor", {"cursor": type.toString().substring("CursorType.".length)});
  }

  void resetCursor() {
    _channel.invokeMethod("resetCursor");
  }
}

class CursorWidget extends StatelessWidget{

  const CursorWidget({Key key, this.child, @required this.cursorType}) : super(key: key);

  final Widget child;

  final CursorType cursorType;

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      builder: (context, hover) {
        return child;
      },
      onHoverStart: (hoverPos) {
        CursorManager.instance.setCursor(cursorType);
      },
      onHoverTickCallback: () {
      },
      onHoverEnd: () {
        CursorManager.instance.resetCursor();
      },
    );
  }

}

