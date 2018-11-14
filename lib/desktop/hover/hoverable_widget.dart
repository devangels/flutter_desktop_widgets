import 'package:flutter/material.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';




typedef HoverBuilder = Widget Function(BuildContext context, bool hovering);

// TODO this class in redundan, remove it
class HoveringBuilder extends HoverableWidget {

  HoveringBuilder({this.hoverBuilder, this.onHoverStart, this.onHoverEnd, this.onHoverTickCallback});

  final HoverBuilder hoverBuilder;

  final VoidCallback onHoverStart;

  final VoidCallback onHoverEnd;

  final VoidCallback onHoverTickCallback;

  @override
  void onHover() {
    if(onHoverStart != null) onHoverStart();
    }

  @override
  void onLeaveHover() {
    if(onHoverEnd != null) onHoverEnd();
  }

  @override
  void onHoverTick() {
    if(onHoverTickCallback != null) onHoverTickCallback();
  }

  Widget build(BuildContext context, bool hovering) => hoverBuilder(context, hovering);
}