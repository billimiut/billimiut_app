import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class KakaoLoginScreen extends StatefulWidget {
  const KakaoLoginScreen({super.key});

  @override
  State<KakaoLoginScreen> createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends State<KakaoLoginScreen> {
  InAppWebViewController? webViewController;
  @override
  Widget build(BuildContext context) {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var uri = Uri.parse('$apiEndPoint/users/login/kakao');
    var webUri = WebUri(uri.toString());
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: webUri,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) async {
          // 콜백 url 감지
          if (url.toString().contains('/users/login/kakao/callback')) {
            // 콜백 URL에서 body 내용 추출
            String? response = await controller.evaluateJavascript(
                source: "document.body.innerText");
            Navigator.pop(context, response);
          }
        },
      ),
    );
  }
}
