import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'menu.dart';
import '../navigation/navigation_controls.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key, required this.controller}) : super(key: key);

  final Completer<WebViewController> controller;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  var loadingPercentage = 0;

  @override
  void initState() {
    //To enable the Hybrid Composition mode for Android devices
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter WebView'), actions: [
        NavigationControls(controller: widget.controller),
        Menu(controller: widget.controller)
      ]),
      body: Stack(
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            debuggingEnabled: true,
              initialUrl: 'https://flutter.dev',
              onWebViewCreated: (webViewController) {
                widget.controller.complete(webViewController);
              },

              //Page load getting started
              onPageStarted: (url) {
                updateState(0);
              },

              //Page is being loaded
              onProgress: (progress) {
                updateState(progress);
              },

              //Page loading completed
              onPageFinished: (url) {
                updateState(100);
              },

              //navigation delegate to intercept webview navigation
              navigationDelegate: (navigation) {
                final host = Uri.parse(navigation.url).host;
                if (host.contains('youtube.com')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Blocking navigation to $host',
                      ),
                    ),
                  );
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              }),
          if (loadingPercentage < 100)
            Positioned(
              child: LinearProgressIndicator(
                color: Colors.red,
                value: loadingPercentage / 100.0,
              ),
            ),
        ],
      ),
    );
  }

  void updateState(int progress) {
    setState(() {
      loadingPercentage = progress;
    });
  }
}
