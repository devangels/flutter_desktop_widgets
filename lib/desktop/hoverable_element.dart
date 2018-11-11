


import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_desktop_widgets/desktop/hover_manager.dart';
import 'package:flutter_desktop_widgets/desktop/hoverable_widget.dart';
import 'package:flutter/scheduler.dart';



class HoverableWidget extends RenderObjectWidget {


  // TODO I want to accept a builder here so SingleChildRenderObjectWidget is probably not the right fit
  HoverableWidget({this.builder});

  /// Called at layout time to construct the widget tree. The builder must not
  /// return null.
  final HoverBuilder builder;

  void onHover() {

  }

  void onLeaveHover() {

  }

  void onHoverTick() {

  }

  @override
  HoverableElement createElement() => HoverableElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => HoverableRenderBox(context as HoverableElement);

}


// TODO same as above, we need a builder. The probem with ComponentElement is, that it has no RenderObject
class HoverableElement extends RenderObjectElement {
  HoverableElement(HoverableWidget widget) : super(widget);


  @override
  HoverableWidget get widget => super.widget;

  @override
  HoverableRenderBox get renderObject => super.renderObject;

  Element _child;


  bool _hovering = false;

  void onHoverTick() {
    widget.onHoverTick();
  }

  void hoverStarted() {
    _hovering = true;
    print("HOVER JUST STARTED");
    widget.onHover();
    markNeedsBuild();
  }

  void hoverEnd() {
    _hovering = false;
    print("HOVER IS NO OVER");
    widget.onLeaveHover();
    markNeedsBuild();
  }


  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    assert(_child == null);
    markNeedsBuild();
    _firstBuild();
    assert(_child != null);
  }

  void _firstBuild() {
    rebuild();
  }

  @override
  void unmount() {
    super.unmount();
    HoverManager.instance.removeElement(this);
    print("IM GONE BYE");
  }


  @override
  void performRebuild() {
    Widget built = widget.builder(this, _hovering);
    _child = updateChild(_child, built, null);
    assert(_child != null);
   // renderObject.markNeedsLayout();
    super.performRebuild(); // Calls widget.updateRenderObject (a no-op in this case).
  }



  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null)
      visitor(_child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
  }


  @override
  void update(HoverableWidget newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderObject.markNeedsLayout();
  }


  @override
  void insertChildRenderObject(RenderObject child, dynamic slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject = this.renderObject;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final HoverableRenderBox renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}


class HoverableRenderBox extends RenderProxyBox {


  HoverableRenderBox(this.hoverableElement2);

  final HoverableElement hoverableElement2;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final Offset topLeft = localToGlobal(Offset.zero);
    Rect pos = Rect.fromPoints(topLeft, Offset(topLeft.dx + size.width, topLeft.dy + size.height));
    HoverManager.instance.updateBox(hoverableElement2, pos);

  }


  @override
  void performLayout() {
      if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }

  }

}
