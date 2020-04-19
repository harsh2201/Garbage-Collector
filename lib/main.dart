import 'package:GarbageCollectorApp/login_screen.dart';
import 'package:GarbageCollectorApp/transition_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dashboard_screen.dart';
import 'feed.dart';
import 'upload_page.dart';
import 'dart:async';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'create_account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'models/user.dart';

final auth = FirebaseAuth.instance;
// final googleSignIn = GoogleSignIn();
final ref = Firestore.instance.collection('insta_users');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

User currentUserModel;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // after upgrading flutter this is now necessary

  // enable timestamps in firebase
  Firestore.instance.settings().then((_) {
    print('[Main] Firestore timestamps in snapshots set');
  }, onError: (_) => print('[Main] Error setting timestamps in snapshots'));
  runApp(GarbageCollector());
}

Future<Null> _ensureLoggedIn(BuildContext context) async {
  // GoogleSignInAccount user = googleSignIn.currentUser;
  final FirebaseUser user = await auth.currentUser();
  if (user == null) {
    // user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    // await googleSignIn.signIn();

    await auth.signInWithEmailAndPassword(
        email: "harsh@gmail.com", password: "password");
  }
  await tryCreateUserRecord(context);

  // if (await auth.currentUser() == null) {
  // final GoogleSignInAccount googleUser = await googleSignIn.signIn();
  // final GoogleSignInAuthentication googleAuth =
  //     await googleUser.authentication;

  // final AuthCredential credential = GoogleAuthProvider.getCredential(
  //   accessToken: googleAuth.accessToken,
  //   idToken: googleAuth.idToken,
  // );

  // await auth.signInWithCredential(credential);
  // await auth.createUserWithEmailAndPassword(
  //   email: 'harsh@gmail.com',
  //   password: 'password',
  // );
  //   await auth.signInWithEmailAndPassword(
  //       email: "harsh@gmail.com", password: "password");
  // }
}

Future<Null> _silentLogin(BuildContext context) async {
  // GoogleSignInAccount user = googleSignIn.currentUser;
  final FirebaseUser user = await auth.currentUser();

  if (user == null) {
    // user = await googleSignIn.signInSilently();
    // await tryCreateUserRecord(context);

    await auth.signInWithEmailAndPassword(
        email: "harsh@gmail.com", password: "password");
  }

  if (await auth.currentUser() == null && user != null) {
    // final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    // final GoogleSignInAuthentication googleAuth =
    //     await googleUser.authentication;

    // final AuthCredential credential = GoogleAuthProvider.getCredential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );

    // await auth.signInWithCredential(credential);
    // await auth.createUserWithEmailAndPassword(
    //   email: 'harsh@gmail.com',
    //   password: 'password',
    // );
    await auth.signInWithEmailAndPassword(
        email: "harsh@gmail.com", password: "password");
  }
}

Future<Null> _setUpNotifications() async {
  if (Platform.isAndroid) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: " + token);

      Firestore.instance
          .collection("insta_users")
          .document(currentUserModel.id)
          .updateData({"androidNotificationToken": token});
    });
  }
}

Future<void> tryCreateUserRecord(BuildContext context) async {
  // GoogleSignInAccount user = googleSignIn.currentUser;
  final FirebaseUser user = await auth.currentUser();
  if (user == null) {
    return null;
  }
  print(user);
  DocumentSnapshot userRecord = await ref.document(user.uid).get();
  if (userRecord.data == null) {
    // no user record exists, time to create

    String userName = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Center(
                child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: Text('Fill out missing data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: ListView(
                      children: <Widget>[
                        Container(
                          child: CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0) {
      ref.document(user.uid).setData({
        "id": user.uid,
        "username": userName,
        "photoUrl": "https://bit.ly/CZHarshAvatar",
        "email": user.email,
        "displayName": "display",
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

class GarbageCollector extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Product Management',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: Colors.blue,
          buttonColor: Colors.pink,
          primaryIconTheme: IconThemeData(color: Colors.black)),
      home: HomePage(title: 'Grabage Collector App'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

PageController pageController;

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool triedSilentLogin = false;
  bool setupNotifications = false;

  MaterialApp buildLoginPage() {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.orange,
        cursorColor: Colors.orange,
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          display2: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            // fontWeight: FontWeight.w400,
            color: Colors.orange,
          ),
          button: TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          caption: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurple[300],
          ),
          display4: TextStyle(fontFamily: 'Quicksand'),
          display3: TextStyle(fontFamily: 'Quicksand'),
          display1: TextStyle(fontFamily: 'Quicksand'),
          headline: TextStyle(fontFamily: 'NotoSans'),
          title: TextStyle(fontFamily: 'NotoSans'),
          subhead: TextStyle(fontFamily: 'NotoSans'),
          body2: TextStyle(fontFamily: 'NotoSans'),
          body1: TextStyle(fontFamily: 'NotoSans'),
          subtitle: TextStyle(fontFamily: 'NotoSans'),
          overline: TextStyle(fontFamily: 'NotoSans'),
        ),
      ),
      home: LoginScreen(),
      navigatorObservers: [TransitionRouteObserver()],
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
      },
    );
    // return Scaffold(
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.only(top: 240.0),
    //       child: Column(
    //         children: <Widget>[
    //           Text(
    //             'Waste Product Management',
    //             style: TextStyle(
    //                 fontSize: 60.0,
    //                 fontFamily: "Billabong",
    //                 color: Colors.black),
    //           ),
    //           Padding(padding: const EdgeInsets.only(bottom: 100.0)),
    //           GestureDetector(
    //             onTap: login,
    //             child: Image.asset(
    //               "assets/images/google_signin_button.png",
    //               width: 225.0,
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Future<FirebaseUser> getFireUser() async => await auth.currentUser();

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      print(currentUserModel);
      // silentLogin(context);
    }

    // final FirebaseUser user = await auth.currentUser();

    if (setupNotifications == false && currentUserModel != null) {
      setUpNotifications();
    }

    // return StreamBuilder(
    //     stream: Firestore.instance
    //         .collection('insta_users')
    //         .document(profileId)
    //         .snapshots(),
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData)
    //         return Container(
    //             alignment: FractionalOffset.center,
    //             child: CircularProgressIndicator());

    //       User user = User.fromDocument(snapshot.data);

    //       if (user.followers.containsKey(currentUserId) &&
    //           user.followers[currentUserId] &&
    //           followButtonClicked == false) {
    //         isFollowing = true;
    //       }

    //       return Scaffold(
    //           appBar: AppBar(
    //             title: Text(
    //               user.username,
    //               style: const TextStyle(color: Colors.black),
    //             ),
    //             backgroundColor: Colors.white,
    //           ),
    //           body: ListView(
    //             children: <Widget>[
    //               Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: Column(
    //                   children: <Widget>[
    //                     Row(
    //                       children: <Widget>[
    //                         CircleAvatar(
    //                           radius: 40.0,
    //                           backgroundColor: Colors.grey,
    //                           backgroundImage: NetworkImage(user.photoUrl),
    //                         ),
    //                         Expanded(
    //                           flex: 1,
    //                           child: Column(
    //                             children: <Widget>[
    //                               Row(
    //                                 mainAxisSize: MainAxisSize.max,
    //                                 mainAxisAlignment:
    //                                     MainAxisAlignment.spaceEvenly,
    //                                 children: <Widget>[
    //                                   buildStatColumn("posts", postCount),
    //                                   buildStatColumn("followers",
    //                                       _countFollowings(user.followers)),
    //                                   buildStatColumn("following",
    //                                       _countFollowings(user.following)),
    //                                 ],
    //                               ),
    //                               Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.spaceEvenly,
    //                                   children: <Widget>[
    //                                     buildProfileFollowButton(user)
    //                                   ]),
    //                             ],
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                     Container(
    //                         alignment: Alignment.centerLeft,
    //                         padding: const EdgeInsets.only(top: 15.0),
    //                         child: Text(
    //                           user.displayName,
    //                           style: TextStyle(fontWeight: FontWeight.bold),
    //                         )),
    //                     Container(
    //                       alignment: Alignment.centerLeft,
    //                       padding: const EdgeInsets.only(top: 1.0),
    //                       child: Text(user.bio),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               Divider(),
    //               buildImageViewButtonBar(),
    //               Divider(height: 0.0),
    //               buildUserPosts(),
    //             ],
    //           ));
    //     });

    return FutureBuilder<FirebaseUser>(
        future: auth.currentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> user) {
          print("User");
          print(currentUserModel);
          tryCreateUserRecord(context);
          if (user.hasData) {
            return (user.data == null)
                ? buildLoginPage()
                : Scaffold(
                    body: PageView(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Feed(),
                        ),
                        // Container(color: Colors.white, child: SearchPage()),
                        Container(
                          color: Colors.white,
                          child: Uploader(),
                        ),
                        // Container(
                        //     color: Colors.white, child: ActivityFeedPage()),
                        Container(
                            color: Colors.white,
                            child: ProfilePage(
                              userId: user.data.uid,
                              currentUserId: user.data.uid,
                            )),
                        // child: ProfilePage(
                        //   userId: "id",
                        // )),
                      ],
                      controller: pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: onPageChanged,
                    ),
                    bottomNavigationBar: CupertinoTabBar(
                      backgroundColor: Colors.white,
                      items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home,
                                color:
                                    (_page == 0) ? Colors.black : Colors.grey),
                            title: Container(height: 0.0),
                            backgroundColor: Colors.white),
                        // BottomNavigationBarItem(
                        //     icon: Icon(Icons.search,
                        //         color:
                        //             (_page == 1) ? Colors.black : Colors.grey),
                        //     title: Container(height: 0.0),
                        //     backgroundColor: Colors.white),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.add_circle,
                                color:
                                    (_page == 1) ? Colors.black : Colors.grey),
                            title: Container(height: 0.0),
                            backgroundColor: Colors.white),
                        // BottomNavigationBarItem(
                        //     icon: Icon(Icons.star,
                        //         color:
                        //             (_page == 2) ? Colors.black : Colors.grey),
                        //     title: Container(height: 0.0),
                        //     backgroundColor: Colors.white),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.person,
                                color:
                                    (_page == 2) ? Colors.black : Colors.grey),
                            title: Container(height: 0.0),
                            backgroundColor: Colors.white),
                      ],
                      onTap: navigationTapped,
                      currentIndex: _page,
                    ),
                  );
          } else {
            return buildLoginPage();
          }
        });
    // return FutureBuilder<FirebaseUser>(
    //   future: getFireUser(),
    //   builder: (context, AsyncSnapshot<FirebaseUser> user) {
    //     if (user.data != null) {
    //       return (currentUserModel == null)
    //     ? buildLoginPage()
    //     : Scaffold(
    //         body: PageView(
    //           children: [
    //             Container(
    //               color: Colors.white,
    //               child: Feed(),
    //             ),
    //             Container(color: Colors.white, child: SearchPage()),
    //             Container(
    //               color: Colors.white,
    //               child: Uploader(),
    //             ),
    //             Container(color: Colors.white, child: ActivityFeedPage()),
    //             Container(
    //                 color: Colors.white,
    //                 child: ProfilePage(
    //                   userId: user.data.uid,
    //                 )),
    //             // child: ProfilePage(
    //             //   userId: "id",
    //             // )),
    //           ],
    //           controller: pageController,
    //           physics: NeverScrollableScrollPhysics(),
    //           onPageChanged: onPageChanged,
    //         ),
    //         bottomNavigationBar: CupertinoTabBar(
    //           backgroundColor: Colors.white,
    //           items: <BottomNavigationBarItem>[
    //             BottomNavigationBarItem(
    //                 icon: Icon(Icons.home,
    //                     color: (_page == 0) ? Colors.black : Colors.grey),
    //                 title: Container(height: 0.0),
    //                 backgroundColor: Colors.white),
    //             BottomNavigationBarItem(
    //                 icon: Icon(Icons.search,
    //                     color: (_page == 1) ? Colors.black : Colors.grey),
    //                 title: Container(height: 0.0),
    //                 backgroundColor: Colors.white),
    //             BottomNavigationBarItem(
    //                 icon: Icon(Icons.add_circle,
    //                     color: (_page == 2) ? Colors.black : Colors.grey),
    //                 title: Container(height: 0.0),
    //                 backgroundColor: Colors.white),
    //             BottomNavigationBarItem(
    //                 icon: Icon(Icons.star,
    //                     color: (_page == 3) ? Colors.black : Colors.grey),
    //                 title: Container(height: 0.0),
    //                 backgroundColor: Colors.white),
    //             BottomNavigationBarItem(
    //                 icon: Icon(Icons.person,
    //                     color: (_page == 4) ? Colors.black : Colors.grey),
    //                 title: Container(height: 0.0),
    //                 backgroundColor: Colors.white),
    //           ],
    //           onTap: navigationTapped,
    //           currentIndex: _page,
    //         ),
    //       );
    //     } else {
    //       return CircularProgressIndicator();
    //     }
    //   }
    // );
  }

  // void login() async {
  //   await _ensureLoggedIn(context);
  //   setState(() {
  //     triedSilentLogin = true;
  //   });
  // }

  void setUpNotifications() {
    _setUpNotifications();
    setState(() {
      setupNotifications = true;
    });
  }

  void silentLogin(BuildContext context) async {
    // await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  // void getUser(){
  //   tryCreateUserRecord()
  // }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
