import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import './login/flutter_login.dart';
import 'constants.dart';
import 'custom_route.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user.dart';
import 'main.dart';

// final auth = FirebaseAuth.instance;
// final ref = Firestore.instance.collection('insta_users');

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<void> tryCreateUserRecord(String uname) async {
    // GoogleSignInAccount user = googleSignIn.currentUser;
    final FirebaseUser user = await auth.currentUser();
    if (user == null) {
      return null;
    }
    print(user);
    DocumentSnapshot userRecord = await ref.document(user.uid).get();
    if (userRecord.data == null) {
      // no user record exists, time to create

      if (uname != null || uname.length != 0) {
        ref.document(user.uid).setData({
          "id": user.uid,
          "username": user.email,
          "photoUrl": "https://bit.ly/CZHarshAvatar",
          "email": user.email,
          "displayName": user.email,
          "bio": "",
          "followers": {},
          "following": {},
        });

        // ref.document("id").setData({
        //   "id": "id",
        //   "username": "uname",
        //   "photoUrl": "https://bit.ly/CZHarshAvatar",
        //   "email": "harsh@gmail.com",
        //   "displayName": "displayName",
        //   "bio": "",
        //   "followers": {},
        //   "following": {},
        // });
      }
      // userRecord = await ref.document("id").get();
      userRecord = await ref.document(user.uid).get();
    }
    currentUserModel = User.fromDocument(userRecord);
    return null;
  }

  Future<String> _loginUser(LoginData data) async {
    await auth.signInWithEmailAndPassword(
        email: data.name, password: data.password);
    tryCreateUserRecord(data.uname);
    // await tryCreateUserRecord(data.uname);
    // return Future.delayed(loginTime).then((_) {
    //   if (!mockUsers.containsKey(data.name)) {
    //     return 'Username not exists';
    //   }
    //   if (mockUsers[data.name] != data.password) {
    //     return 'Password does not match';
    //   }
    //   return null;
    // });
    return null;
  }

  Future<String> _signUpUser(LoginData data) async {
    await auth.createUserWithEmailAndPassword(
        email: data.name, password: data.password);
    await tryCreateUserRecord(data.uname);
    // return Future.delayed(loginTime).then((_) {
    //   if (!mockUsers.containsKey(data.name)) {
    //     return 'Username not exists';
    //   }
    //   if (mockUsers[data.name] != data.password) {
    //     return 'Password does not match';
    //   }
    // return null;
    // });
    return null;
  }

  Future<String> _recoverPassword(String name) {
    auth.sendPasswordResetEmail(email: name);
    // return Future.delayed(loginTime).then((_) {
    //   if (!mockUsers.containsKey(name)) {
    //     return 'Username not exists';
    //   }
    //   return null;
    // });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.appName,
      // logo: 'assets/images/ecorp.png',
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      // messages: LoginMessages(
      //   usernameHint: 'Username',
      //   passwordHint: 'Pass',
      //   confirmPasswordHint: 'Confirm',
      //   loginButton: 'LOG IN',
      //   signupButton: 'REGISTER',
      //   forgotPasswordButton: 'Forgot huh?',
      //   recoverPasswordButton: 'HELP ME',
      //   goBackButton: 'GO BACK',
      //   confirmPasswordError: 'Not match!',
      //   recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
      //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      //   recoverPasswordSuccess: 'Password rescued successfully',
      // ),
      theme: LoginTheme(
        // primaryColor: Colors.teal,
        // accentColor: Colors.yellow,
        // errorColor: Colors.deepOrange,
        // pageColorLight: Colors.indigo.shade300,
        // pageColorDark: Colors.indigo.shade500,
        titleStyle: TextStyle(
          // color: Colors.greenAccent,
          fontFamily: 'Billabong',
          // letterSpacing: 4,
        ),
        beforeHeroFontSize: 50,
        afterHeroFontSize: 20,
        // bodyStyle: TextStyle(
        //   fontStyle: FontStyle.italic,
        //   decoration: TextDecoration.underline,
        // ),
        // textFieldStyle: TextStyle(
        //   color: Colors.orange,
        //   shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
        // ),
        // buttonStyle: TextStyle(
        //   fontWeight: FontWeight.w800,
        //   color: Colors.yellow,
        // ),
        // cardTheme: CardTheme(
        //   color: Colors.yellow.shade100,
        //   elevation: 5,
        //   margin: EdgeInsets.only(top: 15),
        //   shape: ContinuousRectangleBorder(
        //       borderRadius: BorderRadius.circular(100.0)),
        // ),
        // inputTheme: InputDecorationTheme(
        //   filled: true,
        //   fillColor: Colors.purple.withOpacity(.1),
        //   contentPadding: EdgeInsets.zero,
        //   errorStyle: TextStyle(
        //     backgroundColor: Colors.orange,
        //     color: Colors.white,
        //   ),
        //   labelStyle: TextStyle(fontSize: 12),
        //   enabledBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
        //     borderRadius: inputBorder,
        //   ),
        //   focusedBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
        //     borderRadius: inputBorder,
        //   ),
        //   errorBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(color: Colors.red.shade700, width: 7),
        //     borderRadius: inputBorder,
        //   ),
        //   focusedErrorBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(color: Colors.red.shade400, width: 8),
        //     borderRadius: inputBorder,
        //   ),
        //   disabledBorder: UnderlineInputBorder(
        //     borderSide: BorderSide(color: Colors.grey, width: 5),
        //     borderRadius: inputBorder,
        //   ),
        // ),
        // buttonTheme: LoginButtonTheme(
        //   splashColor: Colors.purple,
        //   backgroundColor: Colors.pinkAccent,
        //   highlightColor: Colors.lightGreen,
        //   elevation: 9.0,
        //   highlightElevation: 6.0,
        //   shape: BeveledRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        //   // shape: CircleBorder(side: BorderSide(color: Colors.green)),
        //   // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        // ),
      ),
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _signUpUser(loginData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacement(FadePageRoute(
              builder: (context) => DashboardScreen(),
            ))
            // .then((_) => false);
        ;
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      showDebugButtons: true,
    );
  }
}
