import 'package:flutter/material.dart';
import 'package:flutter_desktop_widgets/desktop/sizing/resizable_row.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

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
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double one = (constraints.maxWidth / 2);
          double two = (constraints.maxWidth - constraints.maxWidth / 2);
          return ResizableRow(
            initialFlex: [one, two],
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.blue,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
