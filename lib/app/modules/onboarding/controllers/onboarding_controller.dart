import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../auth/views/auth_view.dart';

class OnboardingController extends GetxController with WidgetsBindingObserver {
  final RxBool isVideoInitialized = false.obs;
  late VideoPlayerController videoController;
  final RxBool isChecking = false.obs;

  bool _videoDisposed = false; // ✅ guard

  @override
  void onInit() {
    super.onInit();
    videoController = VideoPlayerController.asset('assets/videos/onboarding_bg.mp4')
      ..initialize().then((_) {
        videoController
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();
        isVideoInitialized.value = true;
      }).catchError((error) {
        debugPrint('Video initialization failed: $error');
        isVideoInitialized.value = false;
      });
  }

  Future<void> _disposeVideo() async {
    if (_videoDisposed) return;
    try {
      if (videoController.value.isInitialized) {
        await videoController.pause();
      }
      await videoController.dispose();
    } catch (e) {
      debugPrint('Dispose video error: $e');
    } finally {
      _videoDisposed = true;
      isVideoInitialized.value = false;
    }
  }

  Future<void> goto() async {
    // ✅ stop video first, then navigate
    await _disposeVideo();
    Get.offAll(() => AuthView(), transition: Transition.noTransition);
  }

  @override
  void onClose() {
    // ✅ also dispose if route is popped without pressing NEXT
    if (!_videoDisposed) {
      try { videoController.dispose(); } catch (_) {}
      _videoDisposed = true;
    }
    super.onClose();
  }
}
