import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPageViewerIletisim extends StatefulWidget {
  const WebPageViewerIletisim({super.key});

  @override
  State<WebPageViewerIletisim> createState() => _WebPageViewerIletisimState();
}

class _WebPageViewerIletisimState extends State<WebPageViewerIletisim> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // Burada sadece izin verilen URL'yi kontrol edin
          if (request.url.startsWith('https://www.finanshub.com/iletisim/')) {
            return NavigationDecision.navigate;
          } else {
            return NavigationDecision.prevent;
          }
        },
      ))
      ..loadRequest(Uri.parse('https://www.finanshub.com/iletisim/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişime Geçin'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
