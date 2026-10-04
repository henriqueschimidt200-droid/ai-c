import 'package:flutter/material.dart';
import '../services/creator_service.dart';
import '../widgets_media.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CreatorService.publicFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _empty();
        return RefreshIndicator(
          onRefresh: () async => await Future<void>.delayed(const Duration(milliseconds: 350)),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 30),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data();
              return _PostCard(key: ValueKey(docs[i].id), id: docs[i].id, data: d);
            },
          ),
        );
      },
    );
  }

  Widget _empty() => Center(child: Padding(padding: const EdgeInsets.all(35), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF8B5CF6).withOpacity(.12)), child: const Icon(Icons.public, size: 42, color: Color(0xFFA78BFA))),
    const SizedBox(height: 18), const Text('A comunidade começa aqui.', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), const Text('Publique uma imagem ou vídeo para criar o primeiro momento do feed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
  ])));
}

class _PostCard extends StatefulWidget {
  final String id; final Map<String, dynamic> data;
  const _PostCard({super.key, required this.id, required this.data});
  @override State<_PostCard> createState() => _PostCardState();
}
class _PostCardState extends State<_PostCard> {
  bool liked = false;
  @override Widget build(BuildContext context) {
    final d = widget.data;
    final type = d['type'] ?? 'Imagem';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF11121E), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withOpacity(.07))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 270, width: double.infinity, child: NetworkMedia(url: d['mediaUrl'], type: type)),
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 12, 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 17, backgroundColor: const Color(0xFF7C3AED), child: Text((d['authorName'] ?? 'C').toString().substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 9), Expanded(child: Text(d['authorName'] ?? 'Criador', style: const TextStyle(fontWeight: FontWeight.w800))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(20)), child: Text(type, style: const TextStyle(fontSize: 11, color: Colors.white70))),
          ]),
          if ((d['prompt'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 11), Text(d['prompt'] ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.4)),
          ],
          const SizedBox(height: 10),
          Row(children: [
            IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 42), onPressed: () async { setState(() => liked = !liked); await CreatorService.toggleLike(widget.id, !liked); }, icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? const Color(0xFFFF4D8D) : Colors.white70)),
            Text('${(d['likes'] ?? 0) + (liked ? 1 : 0)}', style: const TextStyle(color: Colors.white54)),
            const SizedBox(width: 12), const Icon(Icons.mode_comment_outlined, size: 20, color: Colors.white60), const SizedBox(width: 5), const Text('Comentar', style: TextStyle(color: Colors.white54)),
            const Spacer(), IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_outlined, color: Colors.white70)),
          ]),
        ])),
      ]),
    );
  }
}
