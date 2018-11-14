

import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';


HoverManager _hoverManager = HoverManager();

class HoverManager {

  // TODO no static
  static HoverManager instance = _hoverManager;

  final MethodChannel _methodChannel = const MethodChannel('flutter/desktop', JSONMethodCodec() );

  HoverManager() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if(call.method == 'onPositionChanged') {
        final double physicalX = call.arguments['physicalX'];
        final double physicalY = call.arguments['physicalY'];
     //   final Duration timeStamp = Duration(milliseconds: call.arguments['timeStamp']);
        final Offset offset = Offset(physicalX, physicalY);
        _handleHover(offset);
      }
    });
  }

  // TODO SplayTreeMap uses the comperator function to also check for equality which is doesnt work in this case.
 // SplayTreeMap<HoverableElement, Rect> _hoverableElements = SplayTreeMap(_sort);
  Map<HoverableElement, Rect> _hoverableElements = {};

  List<HoverableElement> _currentlyHovering = [];


  /// Because this is private in element
  ///
  /// Sorts the elements so the widgets at the bottom of the tree are first
  /// in the map
  static int _sort(Element a, Element b) {
    if (a.depth < b.depth)
      return 1;
    if (b.depth < a.depth)
      return -1;
    if (b.dirty && !a.dirty)
      return 1;
    if (a.dirty && !b.dirty)
      return -1;
    return 0;
  }

  /// Because RenderObjects might move while the cursor is sitting still,
  /// save the last cursor position and check against it if the position changes
  Offset _lastPosition;


  void _handleHover(Offset position) {
    _lastPosition = position;
    for(HoverableElement element in _hoverableElements.keys) {
      if(_checkCollision(element, position)) {
        break;
      }
    }
  }

  /// Removes the given element from the internal map.
  ///
  /// This means that the element can no longer receive hover events. This is
  /// usually called in the elements [unmount]
  void removeElement(HoverableElement element) {
    _hoverableElements.remove(element);
  }

  /// When the RenderObject moves the a different position this is called.
  ///
  /// Because the hovering state can also change without the cursor moving this
  /// needs to be handled.
  ///
  /// This schedules a post frame callback to handle the hover because we are
  /// currently in the middle of a frame.
  void updateBox(HoverableElement element, Rect pos) {
    assert(element != null);
    assert(pos != null);
    _hoverableElements[element] = pos;

    // TODO can it happen that the depth changes without the element being remounted?

    // Because at the very first frame it is null
    if(_lastPosition != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _checkCollision(element, _lastPosition);
      });
    }
  }



  bool _isInside(Rect rect, double x, double y) {
    if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom) return true;
    return false;
  }

  /// Checks for collision and calls the appropriate element methods.
  ///
  /// Returns whether this was the last operation to do (element absorbed the pointer)
  bool _checkCollision(HoverableElement element, Offset position) {
    if(_isInside(_hoverableElements[element], position.dx, position.dy)) {
      if(!_currentlyHovering.contains(element)) {
        _currentlyHovering.add(element);
        element.hoverStarted();
      } else {
        element.onHoverTick();
      }
      return element.widget.opaque;
    } else if(_currentlyHovering.contains(element)) {
       element.hoverEnd();
      _currentlyHovering.remove(element);
    }

    return false;
  }

}
