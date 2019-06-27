import 'dart:ui';

import 'package:flutter/material.dart';

class BackdropFilterPage extends StatefulWidget {
  @override
  _BackdropFilterPageState createState() => _BackdropFilterPageState();
}

class _BackdropFilterPageState extends State<BackdropFilterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BackdropFilterPageState'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeaXzDjoSY9XYlmhCfYbtvWrTqZ3Dd4jxwtAVtkREjyDqTiBY8ig',
            fit: BoxFit.cover,
          ),
          Center(
            child: BlurRectWidget(
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'BackdropFilter class',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'A widget that applies a filter to the existing painted content and then paints child.'
                      'The filter will be applied to all the area within its parent or ancestor widget\'s clip. If there\'s no clip, the filter will be applied to the full screen.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: 150),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlurOvalWidget(
                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return BlurImagePage();
                      }));
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: BlurOvalWidget(
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                BlurOvalWidget(
                  Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlurOvalWidget extends StatelessWidget {
  final Widget _widget;
  double _padding = 10;

  BlurOvalWidget(this._widget, {double padding = 0}) {
    if (padding != 0) this._padding = padding;
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          color: Colors.white10,
          padding: EdgeInsets.all(_padding),
          child: _widget,
        ),
      ),
    );
  }
}

class BlurRectWidget extends StatelessWidget {
  final Widget _widget;
  double _padding = 10;

  BlurRectWidget(this._widget, {double padding = 0}) {
    if (padding != 0) this._padding = padding;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            color: Colors.white10,
            padding: EdgeInsets.all(_padding),
            child: _widget,
          ),
        ),
      ),
    );
  }
}

class BlurImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Image.network(
                  'https://www.pmw-magazine.com/wp-content/uploads/2018/10/5.-web-2018-10-02_vwms_Polo_GTI_R5_Design_02.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),
                  child: Container(
                    color: Colors.white10,
                  ),
                ),
              ),
              RaisedButton(
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                color: Colors.orangeAccent,
                child: Text(
                  '充钱查看更多',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {},
              )
            ],
          )),
    );
  }
}
