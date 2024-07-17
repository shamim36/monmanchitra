// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:monmanchitra/Screens/pull_to_refresh.dart';
import 'package:monmanchitra/Screens/splash_screen.dart';
import 'package:monmanchitra/mangapro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'MangaPro',
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return WebViewWithSplashScreen();
    return SplashScreen1234();

    //   AnimatedSplashScreen(
    //   backgroundColor: Colors.white,
    //   // splashIconSize: 500,
    //   // duration: 0,
    //   // splash: Center(
    //   //   child: Column(
    //   //     mainAxisAlignment: MainAxisAlignment.center,
    //   //     crossAxisAlignment: CrossAxisAlignment.center,
    //   //     children: [
    //   //       Image.asset(
    //   //         '',
    //   //         // height: 280,
    //   //         // width: 280,
    //   //         // alignment: Alignment.center,
    //   //       ),
    //   //     ],
    //   //   ),
    //   // ),
    //   splashTransition: SplashTransition.slideTransition,
    //   pageTransitionType: PageTransitionType.fade,
    //   nextScreen: WebViewWithSplashScreen(),
    // );
  }
}

class WebViewWithSplashScreen extends StatefulWidget {
  final String url;

  List<Map<String, String>> forward_url = [];

  WebViewWithSplashScreen({required this.url});

  @override
  _WebViewWithSplashScreenState createState() =>
      _WebViewWithSplashScreenState();
}

class _WebViewWithSplashScreenState extends State<WebViewWithSplashScreen> {
  bool isLoading = true;
  late final WebViewController _controller;
  List<String> navigationStack = [];
  late DragGesturePullToRefresh dragGesturePullToRefresh;
  late String currentUrl; //variable to hold current url

  Future<void> addFixedMangaHistory(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final entry = '$url';
    final history = prefs.getStringList('fixedMangaHistory') ?? [];
    history.add(entry);
    await prefs.setStringList('fixedMangaHistory', history);
    setState(() {
      // Assuming _fixedMangaHistory is your list in state where you want to keep track of URLs

      widget.forward_url
          .add({'name': '', 'url': url}); // or whatever structure you need
    });
  }

  @override
  void initState() {
    super.initState();

    dragGesturePullToRefresh = DragGesturePullToRefresh(3000, 10); // Here

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              // Reset current URL when a new page starts loading
              currentUrl = url;
              addFixedMangaHistory(currentUrl);
              // Show loading screen only if it's a forward navigation
              if (navigationStack.isEmpty || navigationStack.last != url) {
                isLoading = true;
              }
              dragGesturePullToRefresh.started(); // Here
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              // Add the URL to the navigation stack if it's a forward navigation
              if (navigationStack.isEmpty || navigationStack.last != url) {
                navigationStack.add(url);
              }
              dragGesturePullToRefresh.finished(); // Here
            });
          },
          onWebResourceError: (WebResourceError error) {
            //debugPrint('MyWebViewWidget:onWebResourceError(): ${error.description}');
            // Hide RefreshIndicator for page reload if showing
            dragGesturePullToRefresh.finished(); // Here
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    dragGesturePullToRefresh // Here
        .setController(_controller)
        .setDragHeightEnd(200)
        .setDragStartYDiff(10)
        .setWaitToRestart(3000);
  }

  Future<bool> _handleBackPressed() async {
    if (await _controller.canGoBack()) {
      // Pop the last URL from the navigation stack
      if (navigationStack.isNotEmpty) {
        navigationStack.removeLast();
      }
      _controller.goBack();
      return false; // Prevent app from exiting
    } else {
      return true; // Allow app to exit
    }
  }

  Future<void> _refreshWebView() async {
    setState(() {
      isLoading = true;
    });
    await _controller.reload();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      strokeWidth: 4,
      onRefresh: dragGesturePullToRefresh.refresh, // Here
      displacement: Material.defaultSplashRadius,
      color: Colors.orange.shade700,
      backgroundColor: Color.fromARGB(0, 0, 0, 0),

      child: Builder(builder: (context) {
        dragGesturePullToRefresh.setContext(context); // Here

        return SafeArea(
          child: WillPopScope(
            onWillPop: _handleBackPressed,
            child: Scaffold(
              //wrap this with safe area............................................................................
              body: Stack(
                children: [
                  WebViewWidget(
                    controller: _controller,
                    gestureRecognizers: {
                      Factory(() => dragGesturePullToRefresh)
                    }, // HERE
                  ),
                  if (isLoading)
                    Center(
                      child: Container(
                        height: 100,
                        // width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image.asset(
                            //   'assets/mangaPro.png',
                            //   height: 150,
                            //   width: 150,
                            // ), // Splash screen image
                            // SizedBox(
                            //   height: 20,
                            // ),
                            // LoadingAnimationWidget.twistingDots(
                            //   leftDotColor: Color.fromARGB(255, 211, 153, 7),
                            //   rightDotColor: Color.fromARGB(249, 41, 40, 40),
                            //   size: 50,

                            // ),
                            LoadingAnimationWidget.staggeredDotsWave(
                                color: Color.fromRGBO(197, 109, 54, 1.0),
                                size: 80)
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
