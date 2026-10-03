import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NetworkMedia extends StatefulWidget {
  final String? url;
  final String type;
  const NetworkMedia({super.key, required this.url, required this.type});
  @override State<NetworkMedia> createState() => _NetworkMediaState();
}

class _NetworkMediaState extends State<NetworkMedia> {
  VideoPlayerController? _controller;
  bool _loadingVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'Vídeo' && (widget.url?.isNotEmpty ?? false)) _initVideo();
  }

  Future<void> _initVideo() async {
    setState(() => _loadingVideo = true);
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    try {
      await c.initialize();
      if (!mounted) { await c.dispose(); return; }
      setState(() { _controller = c; _loadingVideo = false; });
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _loadingVideo = false);
    }
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null || widget.url!.isEmpty) return _placeholder();
    if (widget.type == 'Vídeo') {
      if (_loadingVideo || _controller == null) return _placeholder(icon: Icons.movie_creation_outlined);
      return GestureDetector(
        onTap: () => setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play()),
        child: Stack(fit: StackFit.expand, children: [
          FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller!.value.size.width, height: _controller!.value.size.height, child: VideoPlayer(_controller!))),
          Center(child: DecoratedBox(decoration: BoxDecoration(color: Colors.black.withOpacity(.35), shape: BoxShape.circle), child: Padding(padding: const EdgeInsets.all(10), child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow, size: 28)))),
        ]),
      );
    }
    return CachedNetworkImage(imageUrl: widget.url!, fit: BoxFit.cover, placeholder: (_, __) => _placeholder(), errorWidget: (_, __, ___) => _placeholder());
  }

  Widget _placeholder({IconData icon = Icons.auto_awesome}) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF221544), Color(0xFF0D1730)])),
    child: Center(child: Icon(icon, size: 46, color: Colors.white70)),
  );
}
