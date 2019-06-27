import 'package:cma/firebase_curd.dart';
import 'package:cma/home.dart';
import 'package:cma/messaging_widget.dart';
import 'package:cma/page/blur.dart';
import 'package:cma/push_msg.dart';
import 'package:cma/sign_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String appTitle = 'Firebase messaging';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/sign': (context) => SignInPage(),
        '/pushmsg': (context) => PushMsg(),
        '/firebase': (context) => FirebaseCURD(),
        '/cloudmsg': (context) => MessagingWidget(),
        '/blur': (context) => BackdropFilterPage(),
      },
      //home: SignInPage(),
    );
  }
}
