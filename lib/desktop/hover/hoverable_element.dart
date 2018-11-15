


import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hover_manager.dart';




typedef HoverBuilder = Widget Function(BuildContext context, bool hovering);

class HoveringBuilder extends _HoverableWidget {

  HoveringBuilder({this.builder, this.onHoverStart, this.onHoverEnd, this.onHoverTickCallback}): super(builder: builder);

  final HoverBuilder builder;

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

  Widget build(BuildContext context, bool hovering) => builder(context, hovering);
}

class _HoverableWidget extends RenderObjectWidget {



  // TODO IgnorePointer is not an inherited widget, this is why we can't depend on it.
  // Possible solution it to create an AbsorbHoverWidget
  _HoverableWidget({this.builder, this.opaque = false});

  /// Called at layout time to construct the widget tree. The builder must not
  /// return null.
  final HoverBuilder builder;



  /// If this widget absorbs the hover event
  final bool opaque;

  void onHover() {

  }

  void onLeaveHover() {

  }

  void onHoverTick() {

  }

  @override
  HoverableElement createElement() => new HoverableElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => HoverableRenderBox(context as RenderObjectElement);


}



// TODO MIXIN THe RenderWithChildMixin to
// TODO when hot reloading and chanign something thats inside the builder
// TODO Add static int id to help debugging
// it only updates when hovered over it.
class HoverableElement extends RenderObjectElement implements Comparable<HoverableElement> {
  HoverableElement(_HoverableWidget widget)
      : super(widget) {
    id = idCount++;
    print("Construction Element with id $id");

  }

  static int idCount = 0;

  int id;

  @override
  _HoverableWidget get widget => super.widget;

  @override
  HoverableRenderBox get renderObject => super.renderObject;

  Element _child;

  bool _hovering = false;


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {

  }

  int compareTo(HoverableElement other) {
    if (depth < other.depth)
      return 1;
    if (other.depth < depth)
      return -1;
    return identical(other, this)? 0: 1;
  }


  /// Called by the HoverManager when the cursor moves across the hoverable area.
  void onMouseHover() {
    widget.onHoverTick();
  }

  /// Called by the HoverManager when the hover is started.
  void onMouseEnter() {
    _hovering = true;
    if(owner.debugBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.onHover();
        markNeedsBuild();
      });
    } else {
      widget.onHover();
      markNeedsBuild();
    }
  }


  /// Called by the HoverManager when the hover is ended.
  void onMouseExit() {
    _hovering = false;
    if(owner.debugBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.onLeaveHover();
        markNeedsBuild();
      });
    } else {
      widget.onLeaveHover();
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
  void update(_HoverableWidget newWidget) {
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


// TODO RenderProxyBoxWithHittestBehavior
class HoverableRenderBox extends RenderProxyBox {

  HoverableRenderBox(this.hoverableElement);

  final HoverableElement hoverableElement;


  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final Rect pos =  offset & size;

    if(hoverableElement.id == 1) {
      print("Element ${hoverableElement.id} repainted");
    }

    Matrix4 transform = getTransformTo(null);
    Rect transformedPos = MatrixUtils.transformRect(transform, pos);
    HoverManager.instance.updateBox(hoverableElement, transformedPos);
  }




  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    if(hoverableElement.id == 1) {
      print("Element ${hoverableElement.id} applyied transform");
    }
  }

  @override
  void performResize() {
    super.performResize();

    if(hoverableElement.id == 1) {
      print("Element ${hoverableElement.id} applyied RESIZE");
    }
  }


  @override
  void performLayout() {
    if(hoverableElement.id == 1) {
      print("Element ${hoverableElement.id} performtedLayout");
    }
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }

  }

}


