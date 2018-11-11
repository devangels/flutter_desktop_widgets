import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_widgets/desktop/hoverable_widget.dart';

class CursorWidget extends StatefulWidget {

  const CursorWidget({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _CursorWidgetState createState() => new _CursorWidgetState();
}

class _CursorWidgetState extends State<CursorWidget> {

  final MethodChannel _channel = MethodChannel("Cursor", JSONMethodCodec());

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      hoverBuilder: (context, hover) {
        return widget.child;
      },
      onHoverStart: () {
        _channel.invokeMethod("changeCursor");
      },
      onHoverTickCallback: () {
      },
      onHoverEnd: () {
        _channel.invokeMethod("resetCursor");
      },
    );
  }
}

