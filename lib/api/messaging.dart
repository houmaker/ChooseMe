import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAAAfYXpvw:APA91bEevzPz1dQT0Md8NB9VNUIXVP_agFLx57zt4c-buNK4EWGIKGFcKoE2rt1XLgrBRVJE3bSlI67uuy4195ZTrEK6gUaQg_q2iaTeAqo1MF9iysNUHo9W4styB2qwdf9ai_VdKUmP';

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'time': '18:05',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );

  static Future<Response> sendToNew({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post('https://fcm.googleapis.com/fcm/send',
          body: json.encode({
            'message': {
              'topic': 'news',
              'notification': {'body': '$body', 'title': '$title'},
              'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                'story_id': 'story_12345',
              },
              'android': {
                'notification': {
                  'click_action': 'TOP_STORY_ACTIVITY',
                  'body': 'Check out the Top Story'
                }
              },
              'apns': {
                'payload': {
                  'aps': {'category': 'NEW_MESSAGE_CATEGORY'}
                }
              }
            }
          }));
}

/*
DATA='{"notification": {"body": "this is a body","title": "this is a title"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done"}, "to": "/topics/all"}'
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=AAAAAfYXpvw:APA91bEevzPz1dQT0Md8NB9VNUIXVP_agFLx57zt4c-buNK4EWGIKGFcKoE2rt1XLgrBRVJE3bSlI67uuy4195ZTrEK6gUaQg_q2iaTeAqo1MF9iysNUHo9W4styB2qwdf9ai_VdKUmP"


DATA='{"notification": {"body": "this is a body","title": "first"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done"}, "to": "fxT6a38Or3w:APA91bECIp9y4QbSIGfN4bIB-Ht72qH3_-hp_iY3IpqZ7KZtoH2_YjJsfPkqg8JK_OZWBJ7DJ4HkyHIOy2pE2oedIKoRll5Gq2G0hb1Um1rJifrusDoRQOPHAxDCx-oFCmoAW3PVTsoj"}'
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=AAAAAfYXpvw:APA91bEevzPz1dQT0Md8NB9VNUIXVP_agFLx57zt4c-buNK4EWGIKGFcKoE2rt1XLgrBRVJE3bSlI67uuy4195ZTrEK6gUaQg_q2iaTeAqo1MF9iysNUHo9W4styB2qwdf9ai_VdKUmP"

time 沒用
DATA='{"notification": {"body": "this is a body","title": "first"}, "priority": "high", "data": {"time": "18:05", "click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done"}, "to": "fxT6a38Or3w:APA91bECIp9y4QbSIGfN4bIB-Ht72qH3_-hp_iY3IpqZ7KZtoH2_YjJsfPkqg8JK_OZWBJ7DJ4HkyHIOy2pE2oedIKoRll5Gq2G0hb1Um1rJifrusDoRQOPHAxDCx-oFCmoAW3PVTsoj"}'
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=AAAAAfYXpvw:APA91bEevzPz1dQT0Md8NB9VNUIXVP_agFLx57zt4c-buNK4EWGIKGFcKoE2rt1XLgrBRVJE3bSlI67uuy4195ZTrEK6gUaQg_q2iaTeAqo1MF9iysNUHo9W4styB2qwdf9ai_VdKUmP"
*/
