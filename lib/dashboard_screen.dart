import 'package:GarbageCollectorApp/profile_page.dart';
import 'package:GarbageCollectorApp/upload_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import './login/theme.dart';
// import './login/widgets.dart';
import 'feed.dart';
import 'login_screen.dart';
import 'main.dart';
import 'transition_route_observer.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

PageController pageController;

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
        .pushReplacementNamed('/')
        // we dont want to pop the screen, just replace it completely
        .then((_) => false);
  }

  int _page = 0;
  final routeObserver = TransitionRouteObserver<PageRoute>();
  static const headerAniInterval =
      const Interval(.1, .3, curve: Curves.easeOut);
  AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    super.initState();
    pageController = PageController();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  void didPushAfterTransition() => _loadingController.forward();

  // AppBar _buildAppBar(ThemeData theme) {
  //   final menuBtn = IconButton(
  //     color: theme.accentColor,
  //     icon: const Icon(FontAwesomeIcons.bars),
  //     onPressed: () {},
  //   );
  //   final signOutBtn = IconButton(
  //     icon: const Icon(FontAwesomeIcons.signOutAlt),
  //     color: theme.accentColor,
  //     onPressed: () => _goToLogin(context),
  //   );
  //   final title = Center(
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         // Padding(
  //         //   padding: const EdgeInsets.symmetric(vertical: 8.0),
  //         // child: Hero(
  //         //   tag: Constants.logoTag,
  //         //   child: Image.asset(
  //         //     // 'assets/images/ecorp.png',
  //         //     filterQuality: FilterQuality.high,
  //         //     height: 30,
  //         //   ),
  //         // ),
  //         // ),
  //         HeroText(
  //           Constants.appName,
  //           tag: Constants.titleTag,
  //           viewState: ViewState.shrunk,
  //           style: LoginThemeHelper.loginTextStyle,
  //         ),
  //         SizedBox(width: 20),
  //       ],
  //     ),
  //   );

  //   return AppBar(
  //     leading: FadeIn(
  //       child: menuBtn,
  //       controller: _loadingController,
  //       offset: .3,
  //       curve: headerAniInterval,
  //       fadeDirection: FadeDirection.startToEnd,
  //     ),
  //     actions: <Widget>[
  //       FadeIn(
  //         child: signOutBtn,
  //         controller: _loadingController,
  //         offset: .3,
  //         curve: headerAniInterval,
  //         fadeDirection: FadeDirection.endToStart,
  //       ),
  //     ],
  //     title: title,
  //     backgroundColor: theme.primaryColor.withOpacity(.1),
  //     elevation: 0,
  //     textTheme: theme.accentTextTheme,
  //     iconTheme: theme.accentIconTheme,
  //   );
  // }

  Future<FirebaseUser> getFireUser() async => await auth.currentUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: auth.currentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> user) {
          print("User");
          print(user);
          // if (user.hasData) {
          // return (user.data == null)
          // ? null
          // :
          return WillPopScope(
            onWillPop: () => _goToLogin(context),
            child: SafeArea(
                child: Scaffold(
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
                          color: (_page == 0) ? Colors.black : Colors.grey),
                      title: Container(height: 0.0),
                      backgroundColor: Colors.white),
                  // BottomNavigationBarItem(
                  //     icon: Icon(Icons.search,
                  //         color: (_page == 1)
                  //             ? Colors.black
                  //             : Colors.grey),
                  //     title: Container(height: 0.0),
                  //     backgroundColor: Colors.white),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle,
                          color: (_page == 1) ? Colors.black : Colors.grey),
                      title: Container(height: 0.0),
                      backgroundColor: Colors.white),
                  // BottomNavigationBarItem(
                  //     icon: Icon(Icons.star,
                  //         color: (_page == 3)
                  //             ? Colors.black
                  //             : Colors.grey),
                  //     title: Container(height: 0.0),
                  //     backgroundColor: Colors.white),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person,
                          color: (_page == 2) ? Colors.black : Colors.grey),
                      title: Container(height: 0.0),
                      backgroundColor: Colors.white),
                ],
                onTap: navigationTapped,
                currentIndex: _page,
              ),
            )),
          );
          // } else {
          // return null;
          // }
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
  // @override
  // void initState() {

  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
}
