import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPageViewerKunye extends StatefulWidget {
  const WebPageViewerKunye({super.key});

  @override
  State<WebPageViewerKunye> createState() => _WebPageViewerIletisimState();
}

class _WebPageViewerIletisimState extends State<WebPageViewerKunye> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // Burada sadece izin verilen URL'yi kontrol edin
          if (request.url.startsWith('https://www.finanshub.com/kunye/')) {
            return NavigationDecision.navigate;
          } else {
            return NavigationDecision.prevent;
          }
        },
      ))
      ..loadRequest(Uri.parse('https://www.finanshub.com/kunye/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Künye'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
