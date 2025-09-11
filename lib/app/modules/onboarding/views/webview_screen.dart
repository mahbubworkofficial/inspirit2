import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../res/colors/app_color.dart';
import '../../../../widgets/show_custom_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/successfully_view.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final AuthController controller = Get.put(AuthController());

  final String successUrl = 'https://api.example.com/success';
  final String cancelUrl = 'https://api.example.com/cancel';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optionally show progress
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('WebView page started: $url');
          },
          onPageFinished: (String url) {
            debugPrint('WebView page finished: $url');
            if (url.startsWith(successUrl)) {
              controller.verify();
              Get.off(() => const SuccessfullyView());
            } else if (url.startsWith(cancelUrl)) {
              Get.back();
              showCustomSnackBar(
                title: 'Payment Cancelled',
                message: 'The payment was cancelled.',
                isSuccess: false,
              );
            }
          },
          // onWebResourceError: (WebResourceError error) {
          //   debugPrint('WebView error: ${error.description}');
          //   Get.snackbar(
          //     'Error',
          //     'Failed to load page: ${error.description}',
          //     snackPosition: SnackPosition.BOTTOM,
          //   );
          // },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView navigation request: ${request.url}');
            if (request.url.startsWith(successUrl)) {
              controller.verify();
              Get.off(() => const SuccessfullyView());
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(cancelUrl)) {
              Get.back();
              showCustomSnackBar(
                title: 'Payment Cancelled',
                message: 'The payment was cancelled.',
                isSuccess: false,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            color: AppColor.textColor,
            fontSize: 20.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}