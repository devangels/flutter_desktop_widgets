import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final MethodChannel channel = MethodChannel("Choose", JSONMethodCodec());

  String imagePath;



  ImageProvider get imageProvider {
    return imagePath == null? null: FileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: Column(
          children: <Widget>[
            imagePath == null? SizedBox() : Expanded(child: Image(image: imageProvider,),),
            RaisedButton(
              onPressed: () async {
                String path = (await channel.invokeMethod("pickFile"))["path"];
                setState(() {
                  imagePath = path;
                });
              },
              child: Text("Pick an image"),
            ),
          ],
        ),
      ),
    );
  }
}
