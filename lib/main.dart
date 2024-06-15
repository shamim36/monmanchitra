import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monmanchitra/Screens/pull_to_refresh.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Mon Manchitra',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.white,
      splashIconSize: 500,
      duration: 3000,
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/greeting.png',
              height: 280,
              width: 280,
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.fade,
      nextScreen: WebViewWithSplashScreen(),
    );
  }
}

class WebViewWithSplashScreen extends StatefulWidget {
  @override
  _WebViewWithSplashScreenState createState() =>
      _WebViewWithSplashScreenState();
}

class _WebViewWithSplashScreenState extends State<WebViewWithSplashScreen> {
  bool isLoading = true;
  late final WebViewController _controller;
  List<String> navigationStack = [];
  late DragGesturePullToRefresh dragGesturePullToRefresh;

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
      ..loadRequest(Uri.parse('https://monmanchitra.com/'));
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
      onRefresh: dragGesturePullToRefresh.refresh, // Here
      child: Builder(builder: (context) {
        dragGesturePullToRefresh.setContext(context); // Here

        return WillPopScope(
          onWillPop: _handleBackPressed,
          child: SafeArea(
            child: Scaffold(
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
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 80,
                              width: 80,
                            ), // Splash screen image
                            SizedBox(
                              height: 20,
                            ),
                            LoadingAnimationWidget.twistingDots(
                              leftDotColor: Color.fromARGB(255, 27, 95, 25),
                              rightDotColor: Color.fromARGB(250, 45, 27, 2),
                              size: 50,
                            ),
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
