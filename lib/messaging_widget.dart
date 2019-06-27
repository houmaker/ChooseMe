import 'package:cma/api/messaging.dart';
import 'package:cma/model/message.dart';
import 'package:cma/page/first_page.dart';
import 'package:cma/page/second_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  String _messageText = 'Waiting for message';
  String _tokenText = 'Waiting for token';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController titleController =
      TextEditingController(text: 'Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Body123');
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    //專門用來接收 FCM 的 ID

    _firebaseMessaging.getToken().then((token) {
      assert(token != null);
      setState(() {
        _tokenText = 'Push Messaging token: $token';
      });
    });

    _firebaseMessaging.subscribeToTopic('all');

    //專門用來接收 FCM 的訊息。
    _firebaseMessaging.configure(
      //當您收到通知並且APP已打開並在前台運行時，將觸發onMessage。
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          _messageText = 'Push Messaging message(onMessage): $message';
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });

        handleRouting(notification);
      },
      //onResume和onLaunch - 收到通知時不會觸發這兩個事件。僅當用戶從通知區域選擇/點擊通知時才觸發它們。
      //如果APP根本沒有運行，則當用戶點擊通知時將觸發onLaunch。從頭開始啟動APP。
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          _messageText = 'Push Messaging message(onLaunch): $message';
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });

        handleRouting(notification);
      },
      //onResume和onLaunch - 收到通知時不會觸發這兩個事件。僅當用戶從通知區域選擇/點擊通知時才觸發它們。
      //如果APP處於後台，則當用戶選擇通知時，將觸發onResume，將APP恢復到前台狀態。
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final notification = message['data'];
        handleRouting(notification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('Setting registered: $setting');
    });
  }

  void handleRouting(dynamic notification) {
    switch (notification['title']) {
      case 'first':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
        break;
      case 'second':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => SecondPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          RaisedButton(
            onPressed: sendNotification,
            child: Text('Send notification to all'),
          ),
          Text('Token:' + _tokenText),
          SizedBox(
            height: 15.0,
          ),
          Text('Message' + _messageText),
          SizedBox(
            height: 15.0,
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(Message message) => ListTile(
        title: Text('Title: ${message.title}'),
        subtitle: Text('Body: ${message.body}'),
      );

  Future sendNotification() async {
    final response = await Messaging.sendToAll(
      title: titleController.text,
      body: bodyController.text,
      // fcmToken: fcmToken,
    );

    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }
}
