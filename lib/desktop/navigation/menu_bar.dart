


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


/// A Menu Bar intended to use on desktop.
///
///
///
class MenuBar extends StatefulWidget {

  const MenuBar({Key key, this.children}) : super(key: key);

  final List<MenuBarTopLevelEntry> children;

  @override
  _MenuBarState createState() => new _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.0,
      child: Row(
        children: widget.children
      ),

    );
  }
}


/// A top level entry in the menu bar
///
/// This are visible all the time (they don't need any unfolding)
class MenuBarTopLevelEntry extends StatefulWidget {


  const MenuBarTopLevelEntry({Key key, this.children, this.text}) : super(key: key);

  final List<MenuBarEntry> children;

  final String text;

  @override
  MenuBarTopLevelEntryState createState() {
    return new MenuBarTopLevelEntryState();
  }
}

class MenuBarTopLevelEntryState extends State<MenuBarTopLevelEntry> {


  /// Opens the menu, this first call ist special because it pushes a new route
  void openMenu() {

    final RenderBox button = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          child: Text("hi"),
        ),
        PopupMenuItem(
          child: Text("2"),
        ),
        PopupMenuItem(
          child: Text("3"),
        ),

      ],
      position: position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openMenu,
      child: Text(widget.text),
    );
  }
}


/// A folder in the menu bar.
///
/// This can be folded or unfolded
class MenuBarFolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}



class MenuBarEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset, this.textDirection);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest - const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top + (size.height - position.top - position.bottom) / 2.0 - selectedItemOffset;
    }

    // Find the ideal horizontal position.
    double x;
    if (position.left > position.right) {
      // Menu button is closer to the right edge, so grow to the left, aligned to the right edge.
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      // Menu button is closer to the left edge, so grow to the right, aligned to the left edge.
      x = position.left;
    } else {
      // Menu button is equidistant from both edges, so grow in reading direction.
      assert(textDirection != null);
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding)
      x = _kMenuScreenPadding;
    else if (x + childSize.width > size.width - _kMenuScreenPadding)
      x = size.width - childSize.width - _kMenuScreenPadding;
    if (y < _kMenuScreenPadding)
      y = _kMenuScreenPadding;
    else if (y + childSize.height > size.height - _kMenuScreenPadding)
      y = size.height - childSize.height - _kMenuScreenPadding;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  _PopupMenuRoute({
    this.position,
    this.items,
    this.initialValue,
    this.elevation,
    this.theme,
    this.barrierLabel,
    this.semanticLabel,
  });

  final RelativeRect position;
  final List<PopupMenuEntry<T>> items;
  final dynamic initialValue;
  final double elevation;
  final ThemeData theme;
  final String semanticLabel;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
        parent: super.createAnimation(),
        curve: Curves.linear,
        reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd)
    );
  }

  @override
  Duration get transitionDuration => _kMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    double selectedItemOffset;
    if (initialValue != null) {
      double y = _kMenuVerticalPadding;
      for (PopupMenuEntry<T> entry in items) {
        if (entry.represents(initialValue)) {
          selectedItemOffset = y + entry.height / 2.0;
          break;
        }
        y += entry.height;
      }
    }

    Widget menu = _PopupMenu<T>(route: this, semanticLabel: semanticLabel);
    if (theme != null)
      menu = Theme(data: theme, child: menu);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              position,
              selectedItemOffset,
              Directionality.of(context),
            ),
            child: menu,
          );
        },
      ),
    );
  }
}

/// Show a popup menu that contains the `items` at `position`.
///
/// If `initialValue` is specified then the first item with a matching value
/// will be highlighted and the value of `position` gives the rectangle whose
/// vertical center will be aligned with the vertical center of the highlighted
/// item (when possible).
///
/// If `initialValue` is not specified then the top of the menu will be aligned
/// with the top of the `position` rectangle.
///
/// In both cases, the menu position will be adjusted if necessary to fit on the
/// screen.
///
/// Horizontally, the menu is positioned so that it grows in the direction that
/// has the most room. For example, if the `position` describes a rectangle on
/// the left edge of the screen, then the left edge of the menu is aligned with
/// the left edge of the `position`, and the menu grows to the right. If both
/// edges of the `position` are equidistant from the opposite edge of the
/// screen, then the ambient [Directionality] is used as a tie-breaker,
/// preferring to grow in the reading direction.
///
/// The positioning of the `initialValue` at the `position` is implemented by
/// iterating over the `items` to find the first whose
/// [PopupMenuEntry.represents] method returns true for `initialValue`, and then
/// summing the values of [PopupMenuEntry.height] for all the preceding widgets
/// in the list.
///
/// The `elevation` argument specifies the z-coordinate at which to place the
/// menu. The elevation defaults to 8, the appropriate elevation for popup
/// menus.
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the menu. It is only used when the method is called. Its corresponding
/// widget can be safely removed from the tree before the popup menu is closed.
///
/// The `semanticLabel` argument is used by accessibility frameworks to
/// announce screen transitions when the menu is opened and closed. If this
/// label is not provided, it will default to
/// [MaterialLocalizations.popupMenuLabel].
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [CheckedPopupMenuItem], a popup menu item with a checkmark.
///  * [PopupMenuButton], which provides an [IconButton] that shows a menu by
///    calling this method automatically.
///  * [SemanticsConfiguration.namesRoute], for a description of edge triggered
///    semantics.
Future<T> showMenu<T>({
  @required BuildContext context,
  RelativeRect position,
  @required List<PopupMenuEntry<T>> items,
  T initialValue,
  double elevation = 8.0,
  String semanticLabel,
}) {
  assert(context != null);
  assert(items != null && items.isNotEmpty);
  assert(debugCheckHasMaterialLocalizations(context));
  String label = semanticLabel;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      label = semanticLabel;
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      label = semanticLabel ?? MaterialLocalizations.of(context)?.popupMenuLabel;
  }

  return Navigator.push(context, _PopupMenuRoute<T>(
    position: position,
    items: items,
    initialValue: initialValue,
    elevation: elevation,
    semanticLabel: label,
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}