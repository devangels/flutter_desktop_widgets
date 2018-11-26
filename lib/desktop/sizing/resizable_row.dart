import 'package:flutter/material.dart';
import 'package:flutter_desktop_widgets/desktop/hover/cursor_widget.dart';

/// PC Widget
///
/// A row which lets the user resize the proportions between the widgets
/// by dragging the edge with the mouse.
class ResizableRow extends StatefulWidget {


  ResizableRow({
    Key key,
    @required this.children,
    @required this.initialFlex,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  })
      : assert(() {
        return true;
  /*  if (initialFlex == null) return false;
    // All values positive or 0.0
    initialFlex.forEach((val) {
      if (val < 0.0) return false;
    });
    // Sum up to 0
    return initialFlex.fold(0.0, (one, two) => one + two) == 1.0;*/
  }()),
        super(key: key);

  final List<Widget> children;

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final CrossAxisAlignment crossAxisAlignment;

  final TextDirection textDirection;

  final VerticalDirection verticalDirection;

  final TextBaseline textBaseline;

  final List<int> initialFlex;


  @override
  _ResizableRowState createState() => new _ResizableRowState();
}

class _ResizableRowState extends State<ResizableRow> {


  List<int> flexValues;

  int currentlyDraggingIndex;


  @override
  void initState() {
    super.initState();
    flexValues = widget.initialFlex;
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      textDirection: widget.textDirection,
      textBaseline: widget.textBaseline,
      verticalDirection: widget.verticalDirection,
      children: widget.children.asMap().map((index, it) {
        return MapEntry(index,
            Expanded(
              flex: flexValues[index],
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                it,
                GestureDetector(
                  onHorizontalDragStart: (details) => onDragStart(index),
                  onHorizontalDragUpdate: onDragUpdate,
                  onHorizontalDragDown: (_) => onDragStart(index),
                  onHorizontalDragCancel: () => print("canceled"),
                  onHorizontalDragEnd: (_) => print("ended"),
                  child: CursorWidget(
                    cursorType: CursorType.ResizeX,
                    child: Container(
                      width: 15.0,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            ));
      }).values.toList(),
    );
  }


  void onDragStart(int index) {
    print("DRAG started");
    currentlyDraggingIndex = index;
  }

  void onDragUpdate(DragUpdateDetails details) {
    print("moving");
    setState(() {
      flexValues[currentlyDraggingIndex] += details.delta.dy.floor();
    });
  }
}
