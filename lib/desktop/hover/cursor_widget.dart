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
class CursorWidget extends StatefulWidget {

  const CursorWidget({Key key, this.child, @required this.cursorType}) : super(key: key);

  final Widget child;

  final CursorType cursorType;

  @override
  _CursorWidgetState createState() => new _CursorWidgetState();
}

class _CursorWidgetState extends State<CursorWidget> {

  final MethodChannel _channel = MethodChannel("Cursor", JSONMethodCodec());

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      builder: (context, hover) {
        return widget.child;
      },
      onHoverStart: (hoverPos) {
        _channel.invokeMethod("changeCursor", {"cursor": widget.cursorType.toString().substring("CursorType.".length)});
      },
      onHoverTickCallback: () {
      },
      onHoverEnd: () {
        _channel.invokeMethod("resetCursor");
      },
    );
  }
}

