


import 'package:flutter/desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class HoverableElement extends ComponentElement {
  HoverableElement(HoverableWidget widget) : super(widget);


  bool _hovering = false;

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    GestureBinding.instance.hoverManager.registerElement(this);
  }



  @override
  void unmount() {
    super.unmount();
    GestureBinding.instance.hoverManager.removeElement(this);
  }

  @override
  HoverableWidget get widget => super.widget;

  void onHoverTick() {
    widget.onHoverTick();
  }

  void hoverStarted() {
    _hovering = true;
    widget.onHover();
    markNeedsBuild();
  }

  void hoverEnd() {
    _hovering = false;
    widget.onLeaveHover();
    markNeedsBuild();
  }

  @override
  Widget build() => widget.build(this, _hovering);

}