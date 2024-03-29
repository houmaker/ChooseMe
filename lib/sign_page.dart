import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
//final FacebookLogin _facebookLogin = FacebookLogin();

class SignInPage extends StatefulWidget {
  final String title = 'Registration';
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: const Text('Sign out'),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                final FirebaseUser user = await _auth.currentUser();
                if (user == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: const Text('No one has signed in.'),
                  ));
                  return;
                }
                _signOut();
                final String uid = user.uid;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(uid + ' has successfully signed out.'),
                ));
              },
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _PhoneSignInSection(Scaffold.of(context)),
            _GoogleSignInSection(),
            _FacebookSignInSection(),
          ],
        );
      }),
    );
  }

  // Example code for sign out.
  void _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  bool _success;
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: const Text('Test sign in with Google'),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _signInWithGoogle()
                  .then((user) => print(user))
                  .catchError((e) => print(e));
            },
            child: const Text('Sign in with Google'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _success == null
                ? ''
                : (_success
                    ? 'Successfully signed in, uid: ' + _userID
                    : 'Sign in failed'),
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  // Example code of how to sign in with google.
  //原範例是void沒有回傳
  Future<FirebaseUser> _signInWithGoogle() async {
    //取得登入
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    //取得授權
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    //得到證書
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //拿到存取用戶資料的token後，就可以取得用戶的姓名,照片url,電話,email,
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print('Signed in : ${user.displayName}');
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
      } else {
        _success = false;
      }
    });

    return user;
  }
}

class _PhoneSignInSection extends StatefulWidget {
  _PhoneSignInSection(this._scaffold);

  final ScaffoldState _scaffold;
  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _message = '';
  String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: const Text('Test sign in with phone number'),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),
        TextFormField(
          controller: _phoneNumberController,
          decoration:
              InputDecoration(labelText: 'Phone number (+x xxx-xxx-xxxx)'),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Phone number (+x xxx-xxx-xxxx)';
            }
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _verifyPhoneNumber();
            },
            child: const Text('Verify phone number'),
          ),
        ),
        TextField(
          controller: _smsController,
          decoration: InputDecoration(labelText: 'Verification code'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _signInWithPhoneNumber();
            },
            child: const Text('Sign in with phone number'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _message,
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  // Exmaple code of how to veify phone number
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      widget._scaffold.showSnackBar(SnackBar(
        content:
            const Text('Please check your phone for the verification code.'),
      ));
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _message = 'Successfully signed in, uid: ' + user.uid;
      } else {
        _message = 'Sign in failed';
      }
    });
  }
}

// Sign in with Facebook.
class _FacebookSignInSection extends StatefulWidget {
  @override
  _FacebookSignInSectionState createState() => _FacebookSignInSectionState();
}

class _FacebookSignInSectionState extends State<_FacebookSignInSection> {
  bool isLogged = false;

  FirebaseUser myUser;

/*方法一
  void _signInWithFacebook() async {
    final facebookLogin = new FacebookLogin();
    final result = await facebookLogin.logInWithReadPermissions(['email']);

    final _token = result.accessToken.token;

    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: _token,
    );

    if (result.status == FacebookLoginStatus.loggedIn) {
      final FirebaseUser user = await _auth.signInWithCredential(credential);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      setState(() {
        if (user != null) {
          print('Successfully signed in with Facebook. ' + user.uid);
        } else {
          print('Failed to sign in with Facebook. ');
        }
      });
    }
  }
*/
  Future<FirebaseUser> _loginWithFacebook() async {
    final facebookLogin = new FacebookLogin();
    final result = await facebookLogin.logInWithReadPermissions(['email']);
    final token = result.accessToken.token;

    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: token,
    );
    print(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      FirebaseUser user = await _auth.signInWithCredential(credential);
      return user;
    }

    return null;
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() {});
    });
  }

  void _logIn() {
    _loginWithFacebook().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLogged
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Name: ' + myUser.displayName),
                Text('Email: ' + myUser.email),
                Image.network(myUser.photoUrl),
                RaisedButton(
                  onPressed: _logOut,
                  child: Text('Sign out'),
                ),
              ],
            )
          : RaisedButton(
              onPressed: _logIn,
              child: Text('Sign in with Facebook'),
            ),
    );
  }
}

/*
  // Example code of how to sign in with Facebook.
  void _signInWithFacebook() async {
    final AuthCredential credential = FacebookAuthProvider.getCredential(
      //原本要自己輸入token，但是使用flutter_facebook_login包，可以幫我們自動去xml找出token
      accessToken: _tokenController.text,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _message = 'Successfully signed in with Facebook. ' + user.uid;
      } else {
        _message = 'Failed to sign in with Facebook. ';
      }
    });
  }
*/
