


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

    );
  }
}


class MenuBarTopLevelEntry extends StatelessWidget {


  const MenuBarTopLevelEntry({Key key, this.children}) : super(key: key);

  final List<MenuBarEntry> children;




  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}


class MenuBarEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
