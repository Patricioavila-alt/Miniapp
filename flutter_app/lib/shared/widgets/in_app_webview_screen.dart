import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InAppWebViewScreen — Cross-platform (Web, Android, iOS)
//
// webview_flutter_web solo soporta loadRequest/loadHtmlString.
// setNavigationDelegate, setJavaScriptMode, reload(), onProgress, etc.
// lanzan UnimplementedError en web. Los llamamos SOLO en mobile (kIsWeb=false).
// ─────────────────────────────────────────────────────────────────────────────
class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();

    if (!kIsWeb) {
      // NavigationDelegate solo disponible en mobile (Android/iOS)
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) {}, // ignora errores de recursos (ads, etc.)
        ),
      );
    }

    _controller.loadRequest(Uri.parse(widget.url));

    // En web el iframe carga solo — ocultamos el spinner tras un breve delay
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: AppTheme.heading3().copyWith(fontSize: 16),
        ),
        actions: [
          // reload() no está soportado en web — solo mostramos el botón en mobile
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: () => _controller.reload(),
              tooltip: 'Recargar',
            ),
          const SizedBox(width: 4),
        ],
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.blue),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

/// Helper — abre [url] en un WebView dentro de la app (todas las plataformas).
Future<void> openWebPortal(
  BuildContext context, {
  required String url,
  required String title,
}) async {
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => InAppWebViewScreen(url: url, title: title),
    ),
  );
}
