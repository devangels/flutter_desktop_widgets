

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_widgets/desktop/hoverable_element.dart';


HoverManager _hoverManager = HoverManager();

class HoverManager {

  // TODO no static
  static HoverManager instance = _hoverManager;

  final MethodChannel _methodChannel = const MethodChannel('flutter/desktop', JSONMethodCodec() );


  HoverManager() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if(call.method == 'onPositionChanged') {
        // TODO when an element receives focus no calls are coming in from the method channel
        final double physicalX = call.arguments['physicalX'];
        final double physicalY = call.arguments['physicalY'];
     //   final Duration timeStamp = Duration(milliseconds: call.arguments['timeStamp']);
        final Offset offset = Offset(physicalX, physicalY);
        handleHover(offset);
      }
    });
  }

  Map<HoverableElement, Rect> map = {};
 // List<Holder> list = [];

  List<HoverableElement> _currentlyHovering = [];

  void handleHover(Offset position) {

    // Boooo
    bool isInside(Rect rect, double x, double y) {
      if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) return true;
      return false;
    }


    for(HoverableElement element in map.keys) {
      if(isInside(map[element], position.dx, position.dy)) {
        if(!_currentlyHovering.contains(element)) {
          _currentlyHovering.add(element);
          element.hoverStarted();
        } else {
          element.onHoverTick();
        }
      } else if(_currentlyHovering.contains(element)) {
        element.hoverEnd();
        _currentlyHovering.remove(element);
      }
    }
  }

  void removeElement(HoverableElement element) {
    map.remove(element);
  }

  void updateBox(HoverableElement hoverableElement2, Rect pos) {
    map[hoverableElement2] = pos;
    print(pos);
  }

}

class Holder {

  Holder(this.pos, this.element);

  final Rect pos;
  final HoverableElement element;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Holder &&
              runtimeType == other.runtimeType &&
              element == other.element;

  @override
  int get hashCode => element.hashCode;



}