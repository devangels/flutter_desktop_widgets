import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter_desktop_widgets/desktop/hoverable_element.dart';
import 'package:flutter_desktop_widgets/desktop/hoverable_widget.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool pushed = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter Demo Home Page'),
      ),
      body: new Center(
       child: Column(
         children: <Widget>[
           AnimatedContainer(height: pushed? 200.0: 0.0, duration: Duration(seconds: 2),),
           HoverableWidget(
             builder: (context, hover) {
               return Container(
                 height: 100.0,
                 width: 100.0,
                 child: GestureDetector(
                   onTap: () {
                      setState(() {
                        pushed = !pushed;
                      });
                   },
                   child: Material(
                     color: Colors.red,
                     elevation: hover? 8.0 : 0.0,
                     child: Center(
                       child: SizedBox(
                         height: 20.0,
                         width: 20.0,
                         child: HoverableWidget(
                           opaque: true,
                           builder: (context, hover) {
                             return Container(
                               height: 30.0,
                               width: 30.0,
                               child: GestureDetector(
                                 onTap: () {
                                   setState(() {
                                     pushed = !pushed;
                                   });
                                 },
                                 child: Material(
                                   color: Colors.green,
                                   elevation: hover? 8.0 : 0.0,
                                 ),
                               ),
                             );
                           },
                         ),
                       ),
                     ),
                   ),
                 ),
               );
             },
           ),
         ],
       ),
      ),
    );
  }
}

