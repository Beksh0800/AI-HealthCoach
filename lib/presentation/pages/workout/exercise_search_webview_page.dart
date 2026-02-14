import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExerciseSearchWebViewPage extends StatefulWidget {
  const ExerciseSearchWebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  State<ExerciseSearchWebViewPage> createState() =>
      _ExerciseSearchWebViewPageState();
}

class _ExerciseSearchWebViewPageState extends State<ExerciseSearchWebViewPage> {
  late final WebViewController _controller;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url) ??
        Uri.parse('https://www.youtube.com/results?search_query=exercise');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
