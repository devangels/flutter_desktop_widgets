import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hover_manager.dart';



class HoverPos {

  HoverPos(this.pos);

  // Global Coordinates
  final Offset pos;
}

typedef OnHoverStart = void Function(HoverPos pos);

typedef HoverBuilder = Widget Function(BuildContext context, bool hovering);


class HoveringBuilder extends RenderObjectWidget {


  // TODO IgnorePointer is not an inherited widget, this is why we can't depend on it.
  // Possible solution it to create an AbsorbHoverWidget
  HoveringBuilder({@required this.builder, this.onHoverStart, this.onHoverEnd, this.onHoverTickCallback, this.opaque = false});


  final OnHoverStart onHoverStart;

  final VoidCallback onHoverEnd;

  final VoidCallback onHoverTickCallback;

  /// Called at layout time to construct the widget tree. The builder must not
  /// return null.
  final HoverBuilder builder;



  /// If this widget absorbs the hover event
  final bool opaque;



  @override
  HoverableElement createElement() => new HoverableElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => HoverableRenderBox(context as RenderObjectElement);

  @override
  void updateRenderObject(BuildContext context, HoverableRenderBox renderObject) {

  }

}


// TODO MIXIN THe RenderWithChildMixin to
// TODO when hot reloading and chanign something thats inside the builder
// TODO Add static int id to help debugging
// it only updates when hovered over it.
class HoverableElement extends RenderObjectElement{
  HoverableElement(HoveringBuilder widget)
      : super(widget);


  @override
  HoveringBuilder get widget => super.widget;

  @override
  HoverableRenderBox get renderObject => super.renderObject;

  Element _child;

  bool _hovering = false;


  int compareTo(HoverableElement other) {
    if (depth < other.depth)
      return 1;
    if (other.depth < depth)
      return -1;
    return identical(other, this)? 0: 1;
  }


  /// Called by the HoverManager when the cursor moves across the hoverable area.
  void onMouseHover() {
    widget.onHoverTickCallback?.call();
  }

  /// Called by the HoverManager when the hover is started.
  void onMouseEnter(HoverPos hoverPos) {
    _hovering = true;
    if(owner.debugBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.onHoverStart?.call(hoverPos);
        markNeedsBuild();
      });
    } else {
      widget.onHoverStart?.call(hoverPos);
      markNeedsBuild();
    }
  }


  /// Called by the HoverManager when the hover is ended.
  void onMouseExit() {
    _hovering = false;
    if(owner.debugBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.onHoverEnd?.call();
        markNeedsBuild();
      });
    } else {
      widget.onHoverEnd?.call();
      markNeedsBuild();
    }
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
  }


  @override
  void performRebuild() {
    Widget built = widget.builder(this, _hovering);
    _child = updateChild(_child, built, null);
    //TODO fix this
    assert(_child != null);
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
  void update(HoveringBuilder newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    markNeedsBuild();
   // renderObject.markNeedsLayout();
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


// TODO RenderProxyBoxWithHittestBehavior
class HoverableRenderBox extends RenderProxyBox {

  HoverableRenderBox(this.hoverableElement);

  final HoverableElement hoverableElement;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final Offset l = localToGlobal(Offset.zero);
    final Rect t = Rect.fromLTWH(l.dx, l.dy, size.width, size.height);

    HoverManager.instance.updateBox(hoverableElement, t);
  }


  /// TODO look at layers and see if we can get a callback when RepaintedBoundary is there

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


