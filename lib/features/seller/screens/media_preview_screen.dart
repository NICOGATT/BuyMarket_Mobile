import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/selected_media.dart';

class MediaPreviewScreen extends StatefulWidget {
  final SelectedMedia media;

  const MediaPreviewScreen({
    super.key,
    required this.media,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.media.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.file(File(widget.media.file.path));
    _videoController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) return;
      setState(() => _isVideoReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar el video');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.media.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: widget.media.isImage
            ? _buildImagePreview()
            : _buildVideoPreview(),
      ),
      floatingActionButton: widget.media.isVideo && _isVideoReady
          ? FloatingActionButton(
              onPressed: () {
                final controller = _videoController!;
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null,
    );
  }

  Widget _buildImagePreview() {
    return InteractiveViewer(
      child: Image.file(
        File(widget.media.file.path),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: Colors.white),
      );
    }

    if (!_isVideoReady || _videoController == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }
}
