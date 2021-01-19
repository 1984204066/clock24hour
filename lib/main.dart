import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clock24hour/bubble.dart';

void main() => runApp(MyApp());
/*
void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '24 hours clock',
      home: new Scaffold(
        backgroundColor: Colors.transparent, //把scaffold的背景色改成透明
        appBar: new AppBar(
          backgroundColor: Colors.transparent, //把appbar的背景色改成透明
          elevation: 1, //appbar的阴影
          title: new Text('休息一下'),
        ),
        body: Center(
            child: BobblePage()
        ),
      ),
    );
  }
}

