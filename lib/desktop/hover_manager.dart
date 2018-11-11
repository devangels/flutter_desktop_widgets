

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/desktop/hoverable_element.dart';
import 'package:flutter/scheduler.dart';

class HoverManager {


  List<Holder> list = [];

  List<Holder> _currentlyHovering = [];

  void handleHover(PointerHoverEvent hoverEvent) {



    bool isInside(Rect rect, double x, double y) {
      if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) return true;
      return false;
    }


    for(Holder holder in list) {
      if(isInside(holder.pos, hoverEvent.position.dx, hoverEvent.position.dy)) {
        if(!_currentlyHovering.contains(holder)) {
          _currentlyHovering.add(holder);
          holder.element.hoverStarted();
        } else {
          holder.element.onHoverTick();
        }
      } else if(_currentlyHovering.contains(holder)) {
        holder.element.hoverEnd();
        _currentlyHovering.remove(holder);
      }
    }
  }

  void registerElement(HoverableElement element) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final RenderBox box = element.findRenderObject();
      final Offset topLeft = box.localToGlobal(Offset.zero);
      final Size size = box.size;
      Rect pos = Rect.fromPoints(topLeft, Offset(topLeft.dx + size.width, topLeft.dy + size.height));
      list.add(Holder(pos, element));

    });
  }

  void removeElement(HoverableElement element) {

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