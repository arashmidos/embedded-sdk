import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Embedded VPN Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('sample.example.com/proxy');
  static const String outlineKey = 'ss://<YOUR_OUTLINE_KEY>';
  static const String port = '54321';
  final logger = Logger(printer: PrettyPrinter());
  late InAppWebViewController _controller;
  var loadingPercentage = 0;

  Future<void> startProxy() async {
    try {
      logger.d('Starting outline proxy on port $port ...');
      final result = await platform.invokeMethod<String>('startOutlineProxy', {"key": outlineKey, "port": port});
      logger.d('result: $result');
      await enableWebviewProxy();
      _controller.reload();
    } on PlatformException catch (e) {
      logger.d('Exception in starting proxy $e');
    }
  }

  Future<void> stopProxy() async {
    try {
      logger.d('Stopping outline proxy');
      final result = await platform.invokeMethod<String>('stopOutlineProxy');
      logger.d('result: $result');
      await disableWebviewProxy();
      _controller.reload();
    } on PlatformException catch (e) {
      logger.d('Exception in stopping proxy $e');
    }
  }

  Future<void> enableWebviewProxy() async {
    if (Platform.isIOS) return;
    var proxyAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);

    if (proxyAvailable) {
      ProxyController proxyController = ProxyController.instance();

      await proxyController.clearProxyOverride();
      await proxyController.setProxyOverride(
          settings: ProxySettings(
        proxyRules: [ProxyRule(url: 'localhost:$port')],
      ));
    }
  }

  Future<void> disableWebviewProxy() async {
    if (Platform.isIOS) return;
    ProxyController proxyController = ProxyController.instance();
    await proxyController.clearProxyOverride();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Embedded VPN Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: startProxy,
                child: const Text('Start Proxy'),
              ),
              ElevatedButton(
                onPressed: stopProxy,
                child: const Text('Stop Proxy'),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.x.com'))),
                child: const Text('X'),
              ),
              ElevatedButton(
                onPressed: () => _controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.youtube.com'))),
                child: const Text('Youtube'),
              ),
              ElevatedButton(
                onPressed: () => _controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://web.telegram.org'))),
                child: const Text('Telegram'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
              child: Stack(
            children: [
              InAppWebView(
                  initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://www.x.com'),
                  ),
                  onWebViewCreated: (controller) async {
                    _controller = controller;
                    // controller.loadUrl(urlRequest: null);
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      loadingPercentage = progress;
                    });
                  },
                  onLoadStart: (controller, uri) {
                    setState(() {
                      loadingPercentage = 0;
                    });
                  },
                  onLoadStop: (controller, uri) {
                    setState(() {
                      loadingPercentage = 100;
                    });
                  }),
              if (loadingPercentage < 100)
                LinearProgressIndicator(
                  value: loadingPercentage / 100,
                ),
            ],
          ))
        ],
      ),
    );
  }
}
