


import 'package:flutter/material.dart';


/// A widget which calls the right layout depending on the size
///
/// This is usually extended by a widget which represents a whole page.
/// In such situation it might be nicer to have completely different build methods because
/// the layout is quite different (Playing navigation in a [Row] vs in a [NavigationDrawer]
///
/// TODO is this useful?
abstract class PageLayoutWidget extends StatelessWidget {


  @protected
  double get breakpoint => 500.0;



  Widget buildSmall(BuildContext context);
  Widget buildBig(BuildContext context);


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if(constraints.maxWidth > breakpoint) {
        return buildBig(context);
      } else {
        return buildSmall(context);
      }
    },);
  }
}
