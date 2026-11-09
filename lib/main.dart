import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const akmmcWebsiteUrl = 'https://akmmc.edu.bd/';

void main() {
  runApp(const AkmmcApp());
}

class AkmmcApp extends StatelessWidget {
  const AkmmcApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF123B5D);

    return MaterialApp(
      title: 'AKMMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        useMaterial3: true,
      ),
      home: const AkmmcHomePage(),
    );
  }
}

class AkmmcHomePage extends StatefulWidget {
  const AkmmcHomePage({super.key});

  @override
  State<AkmmcHomePage> createState() => _AkmmcHomePageState();
}

class _AkmmcHomePageState extends State<AkmmcHomePage> {
  static final _homeUri = Uri.parse(akmmcWebsiteUrl);

  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _canGoBack = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loadError = null;
              _loadingProgress = 0;
            });
          },
          onPageFinished: (_) async {
            final canGoBack = await _controller.canGoBack();
            if (!mounted) return;
            setState(() {
              _loadingProgress = 100;
              _canGoBack = canGoBack;
              _loadError = null;
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _loadError = error.description;
              _loadingProgress = 0;
            });
          },
        ),
      )
      ..loadRequest(_homeUri);
  }

  Future<void> _handleSystemBack(bool didPop) async {
    if (didPop) return;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) => _handleSystemBack(didPop),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (_loadingProgress < 100)
                LinearProgressIndicator(
                  value: _loadingProgress == 0 ? null : _loadingProgress / 100,
                  minHeight: 2,
                ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loadError != null)
                      ColoredBox(
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 48,
                                  color: Color(0xFF123B5D),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Could not load the website',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _loadError = null;
                                    });
                                    _controller.reload();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
