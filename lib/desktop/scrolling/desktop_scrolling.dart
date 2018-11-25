

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hover_manager.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';

/// This is a way of implementing the ability to scroll on desktop using the scroll wheel without
/// changing any platform code
class DesktopScrolling extends StatefulWidget {


  const DesktopScrolling({Key key, this.controller, this.child, this.scrollSpeed = 35.0, this.reversed = false}) : super(key: key);

  final ScrollController controller;

  final Widget child;

  /// 1 being very very slow
  /// 40 being pretty fast
  final double scrollSpeed;

  /// If the list ist reversed
  final bool reversed;

  @override
  DesktopScrollingState createState() => DesktopScrollingState();
}

class DesktopScrollingState extends State<DesktopScrolling> {



  bool _hastFocus = false;



  @override
  void initState() {
    super.initState();
    HoverManager.instance.addScrollListener(_handleScroll);
  }


  void _handleScroll(Offset offset) {
    if(!_hastFocus) return;
    widget.controller.jumpTo(widget.controller.position.pixels + (offset.dy * direction * widget.scrollSpeed));
  }

  int get direction => widget.reversed? 1: -1;

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      onHoverStart: (_) {
        _hastFocus = true;
      },
      onHoverEnd: () {
        _hastFocus = false;
      },
      builder: (context, _) => widget.child,
    );
  }
}
