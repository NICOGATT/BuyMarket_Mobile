import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/routes/app_routes.dart';
import '../../favorites/services/favorite_services_instances.dart';
import '../services/auth_services_instance.dart';

class StartupVideoScreen extends StatefulWidget {
  const StartupVideoScreen({super.key});

  @override
  State<StartupVideoScreen> createState() => _StartupVideoScreenState();
}

class _StartupVideoScreenState extends State<StartupVideoScreen> {
  late final VideoPlayerController _videoController;
  bool _isVideoReady = false;
  bool _hasVideoStarted = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/startup.mp4',
    );
    _videoController.addListener(_handleVideoProgress);
    unawaited(_startApp());
  }

  void _handleVideoProgress() {
    if (_hasVideoStarted ||
        !_videoController.value.isInitialized ||
        _videoController.value.position <= Duration.zero ||
        !mounted) {
      return;
    }

    setState(() => _hasVideoStarted = true);
  }

  Future<void> _startApp() async {
    final sessionFuture = _restoreSession();
    final videoFuture = _playStartupVideo();

    await Future.wait([sessionFuture, videoFuture]);
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      authServices.isLoggeIn ? AppRoutes.home : AppRoutes.authWelcome,
      (route) => false,
    );

    unawaited(_loadFavorites());
  }

  Future<void> _restoreSession() async {
    try {
      await authServices.checkSession();
    } catch (error) {
      debugPrint('Error restoring session: $error');
    }
  }

  Future<void> _playStartupVideo() async {
    try {
      await _videoController.initialize();
      if (!mounted) return;

      setState(() => _isVideoReady = true);
      await _videoController.setLooping(false);
      await _videoController.play();
      await _waitForVideoToFinish();
    } catch (error) {
      debugPrint('Error playing startup video: $error');
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }

  Future<void> _waitForVideoToFinish() async {
    final completion = Completer<void>();

    void listener() {
      final value = _videoController.value;
      if (!value.isInitialized || value.duration == Duration.zero) return;

      final remaining = value.duration - value.position;
      if (remaining <= const Duration(milliseconds: 120) &&
          !completion.isCompleted) {
        completion.complete();
      }
    }

    _videoController.addListener(listener);
    final duration = _videoController.value.duration;

    try {
      await completion.future.timeout(
        duration + const Duration(seconds: 5),
      );
    } on TimeoutException {
      // Continue to the app if a device does not report video completion.
    } finally {
      _videoController.removeListener(listener);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      await favoritesService.loadFavorites();
    } catch (error) {
      debugPrint('Error loading favorites after startup: $error');
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_handleVideoProgress);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      body: SizedBox.expand(
        child: _isVideoReady
            ? Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                  if (!_hasVideoStarted)
                    Image.asset(
                      'assets/images/startup_first_frame.png',
                      fit: BoxFit.cover,
                    ),
                ],
              )
            : Image.asset(
                'assets/images/startup_first_frame.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
