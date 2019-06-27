//import 'package:cma/messaging_widget.dart';
import 'package:cma/widget/local_notification_widget.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Send Push Notifications'),
        ),
        //body: MessagingWidget(),
        body: LocalNotificationWidget(),
      );
}
