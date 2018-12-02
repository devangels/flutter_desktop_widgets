import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_desktop_widgets/desktop/hover/hoverable_element.dart';


// TODO is is very experimental
//
// Menus should probably be done with the native API to work on all operating systems as intended.
// For example on MAc the MenuBar isn't even inside the application!
//
// On Windows it is also possible to have a menu open which expands beyond the window (resize the application to be really
// small and then open a menu), this is not possible with Flutter because we are constrained to the actual window.

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



class FindableMenu {

  FindableMenu({this.entry, this.key});

  final OverlayEntry entry;

  final GlobalKey<_MenuState> key;
}
mixin MenuNavigator<T extends StatefulWidget> on State<T> {

  // A reference to all entries to close them all
  List<FindableMenu> _openEntries = [];

  FocusScopeNode _focusScopeNode = FocusScopeNode();


  OverlayEntry _openFolderAndCloserOthers(_Menu menu, GlobalKey<_MenuState> globalKey) {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) => menu);
    Overlay.of(context).insert(overlayEntry, above: _MenuBarState._gestureOverlay);

    FocusScope.of(context).setFirstFocus(_focusScopeNode);
    closeAll();
    _openEntries.add(FindableMenu(
      entry: overlayEntry,
      key: globalKey
     ));

    return overlayEntry;
  }


  void closeAll() {
    _openEntries.forEach((it) {
      it?.entry?.remove();
      it?.key?.currentState?.closeAll();
    });
    _openEntries.clear();
  }

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
    return _inheritedMenuBar?.state;
  }
  
  @override
  _MenuBarState createState() => new _MenuBarState();
}

class _MenuBarState extends State<MenuBar> with MenuNavigator<MenuBar>{


  //TODO not static
  static OverlayEntry _gestureOverlay;

  FocusNode node = FocusNode();

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // The menu overlays are inserted over the listener.
    // This way those absorbe pointers but if clicked somewhere else this triggers and closes everything.
    // But it doesnt take away the event, so the same click can also trigger an action.
    Widget gestureDetector = Listener(
      onPointerDown: (_) {
        closeAll();
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
    RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    position = position.shift(Offset(0.0, button.size.height));


    GlobalKey<_MenuState> key = GlobalKey();
    MenuBar.of(context)._openFolderAndCloserOthers(_Menu(
      position: position,
      key: key,
      rect: position.toRect(Offset.zero & overlay.size),
    ), key);

  }

  @override
  Widget build(BuildContext context) {
    return HoveringBuilder(
      onHoverStart: (_) => openMenu(),
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


  /// Opens the menu, this first call ist special because it pushes a new route
  void openMenu() {
    final RenderBox button = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    position = position.shift(Offset(button.size.width, 0.0));

    GlobalKey<_MenuState> key = GlobalKey();
    _Menu.of(context)._openFolderAndCloserOthers(_Menu(
      key: key,
      position: position,
      rect: position.toRect(Offset.zero & overlay.size),
    ), key);

  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: HoveringBuilder(
        onHoverStart: (_) => openMenu(),
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



class _InheritedMenu extends InheritedWidget {
  const _InheritedMenu({
    Key key,
    this.state,
    @required Widget child,

  }) : super(key: key, child: child);

  final _MenuState state;

  @override
  bool updateShouldNotify(_InheritedMenu old) => state != old.state;
}


class _Menu extends StatefulWidget {
  const _Menu({
    Key key,
    @required this.position,
    @required this.rect,
    this.semanticLabel,
  }) : super(key: key);


  final String semanticLabel;

  final RelativeRect position;

  final Rect rect;

  static _MenuState of(BuildContext context) {
    _InheritedMenu _inheritedMenuBar =  context.inheritFromWidgetOfExactType(_InheritedMenu);
    return _inheritedMenuBar?.state;
  }

  @override
  _MenuState createState() {
    return new _MenuState();
  }
}

class _MenuState extends State<_Menu> with MenuNavigator{



  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position.top,
      left: widget.position.left,
      child: _InheritedMenu(
        state: this,
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
      ),
    );
  }
}