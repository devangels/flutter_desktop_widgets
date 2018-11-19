


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';


const Duration _kMenuDuration = Duration(milliseconds: 300);
const double _kBaselineOffsetFromBottom = 20.0;
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuHorizontalPadding = 16.0;
const double _kMenuItemHeight = 48.0;
const double _kMenuDividerHeight = 16.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 8.0;
const double _kMenuWidthStep = 56.0;
const double _kMenuScreenPadding = 8.0;



class _MenuFolder {
  _MenuFolder({this.child, this.id});
  final Widget child;

  final Object id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _MenuFolder &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}


class _InheritedMenuBar extends InheritedWidget {
  const _InheritedMenuBar({
    Key key,
    this.state,
    @required Widget child,

  }) : super(key: key, child: child);

  final _MenuBarState state;

  @override
  bool updateShouldNotify(_InheritedMenuBar old) => state != old.state;
}


/// A Menu Bar intended to use on desktop.
///
///
///
class MenuBar extends StatefulWidget {

  const MenuBar({Key key, this.children}) : super(key: key);

  final List<Widget> children;


  static _MenuBarState of(BuildContext context) {
    _InheritedMenuBar _inheritedMenuBar =  context.inheritFromWidgetOfExactType(_InheritedMenuBar);
    return _inheritedMenuBar.state;
  }
  
  @override
  _MenuBarState createState() => new _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {


  OverlayEntry _gestureOverlay;


  // A reference to all entries to close them all
  List<OverlayEntry> _openEntries = [];

  FocusScopeNode _focusScopeNode = FocusScopeNode();


  @override
  void initState() {
    super.initState();

    // The menu overlays are inserted over the listener.
    // This way those absorbe pointers but if clicked somewhere else this triggers and closes everything.
    // But it doesnt take away the event, so the same click can also trigger an action.
    Widget gestureDetector = Listener(
      onPointerDown: (_) {
        _openEntries.forEach((it) => it.remove());
        _openEntries.clear();
        _focusScopeNode.detach();
      },
      behavior: HitTestBehavior.translucent,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _gestureOverlay = OverlayEntry(builder: (context) => gestureDetector);
      Overlay.of(context).insert(_gestureOverlay);
    });


  }

  @override
  void dispose() {
    _gestureOverlay.remove();
    super.dispose();
  }



  OverlayEntry _addFolder(Widget widget) {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) => widget);
    Overlay.of(context).insert(overlayEntry, above: _gestureOverlay);

    FocusScope.of(context).setFirstFocus(_focusScopeNode);


    _openEntries.add(overlayEntry);


    return overlayEntry;
  }

  void _removeFolder(_MenuFolder folder) {
  // setState(() {
   //   folders.remove(folder);
 //   });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedMenuBar(
      state: this,
      child: Container(
        color: Colors.yellow,
        child: Row(
          children: widget.children.asMap().entries.map((entry) {
            return MenuBarTopLevelEntry(
              child: entry.value,
              onHoverStart: () {

              },
            );
          }).toList()
        ),

      ),
    );
  }
}


/// A top level entry in the menu bar
///
/// This are visible all the time (they don't need any unfolding)
class MenuBarTopLevelEntry extends StatefulWidget {


  const MenuBarTopLevelEntry({Key key, this.children, this.child, this.onHoverStart}) : super(key: key);

  final List<Widget> children;

  final Widget child;

  final VoidCallback onHoverStart;

  @override
  MenuBarTopLevelEntryState createState() =>  MenuBarTopLevelEntryState();
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


    MenuBar.of(context)._addFolder(_Menu(
      position: position,
      rect: position.toRect(Offset.zero & overlay.size),
    ));

  }

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      onHoverStart: (_) => widget.onHoverStart,
      builder: (context, hovering) {
        return Material(
          color: hovering? Colors.purple: Colors.green,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 16.0,
              child: InkWell(
                onTap: openMenu,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}




/// A folder in the menu bar.
///
/// This can be folded or unfolded
class MenuBarFolder extends StatefulWidget {
  @override
  MenuBarFolderState createState() {
    return new MenuBarFolderState();
  }
}

class MenuBarFolderState extends State<MenuBarFolder> {


  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: HoveringBuilder(
        builder: (context, hovering) {
          return Container(
            height: 32.0,
            width: 100.0,
            child: Material(
              color: hovering? Colors.blue : Colors.red,
              child: Text("FOLDER ->"),
            ),
          );
        },
      ),
    );
  }
}



class _Menu extends StatelessWidget {
  const _Menu({
    Key key,
    @required this.position,
    @required this.rect,
    this.semanticLabel,
  }) : super(key: key);


  final String semanticLabel;

  final RelativeRect position;

  final Rect rect;

  @override
  Widget build(BuildContext context) {

    return Positioned(
      top: position.top+ rect.height,
      left: position.left,
      child: GestureDetector(
        onTap: () {
          print("POP UP TAPPED");
        },
        child: SizedBox(
          child: Material(
            child: Column(
              children: <Widget>[
                MenuBarFolder(),
                MenuBarFolder(),
                MenuBarFolder(),
                MenuBarFolder(),
              ],
            ),
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}