import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPageViewerGizlilik extends StatefulWidget {
  const WebPageViewerGizlilik({super.key});

  @override
  State<WebPageViewerGizlilik> createState() => _WebPageViewerIletisimState();
}

class _WebPageViewerIletisimState extends State<WebPageViewerGizlilik> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // Burada sadece izin verilen URL'yi kontrol edin
          if (request.url.startsWith('https://www.finanshub.com/privacy-policy-2/')) {
            return NavigationDecision.navigate;
          } else {
            return NavigationDecision.prevent;
          }
        },
      ))
      ..loadRequest(Uri.parse('https://www.finanshub.com/privacy-policy-2/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Sözleşmesi'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
