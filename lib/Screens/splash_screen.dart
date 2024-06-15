import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:monmanchitra/Screens/web_page.dart';
import 'package:monmanchitra/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  @override
  void initState() {
    super.initState();
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
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              // Add the URL to the navigation stack if it's a forward navigation
              if (navigationStack.isEmpty || navigationStack.last != url) {
                navigationStack.add(url);
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://monmanchitra.com/'));
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
    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: SafeArea(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshWebView,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (isLoading)
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/logo.png'), // Splash screen image
                          LoadingAnimationWidget.twistingDots(
                            leftDotColor: const Color(0xFF1A1A3F),
                            rightDotColor: const Color(0xFFEA3799),
                            size: 200,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
