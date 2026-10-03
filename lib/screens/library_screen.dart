import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/creator_service.dart';
import '../widgets_media.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool publishing = false;

  Future<void> publishFromPhone() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF151625),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Publicar na comunidade',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha uma imagem ou vídeo do celular.',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Imagem'),
                onTap: () => Navigator.pop(context, 'Imagem'),
              ),
              ListTile(
                leading: const Icon(Icons.movie_creation_outlined),
                title: const Text('Vídeo'),
                onTap: () => Navigator.pop(context, 'Vídeo'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;

    final picker = ImagePicker();
    final file = choice == 'Vídeo'
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 92,
          );

    if (file == null) return;

    setState(() => publishing = true);
    try {
      await CreatorService.publishFile(file: file, type: choice);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicado! Sua criação já está online.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder(
          stream: CreatorService.myProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return _empty();

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemBuilder: (_, i) {
                final doc = docs[i];
                final d = doc.data();
                final published = d['published'] == true;

                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11121E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: NetworkMedia(
                          url: d['mediaUrl'],
                          type: d['type'] ?? 'Imagem',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  published ? Icons.public : Icons.lock_outline,
                                  size: 15,
                                  color: published
                                      ? const Color(0xFF67E8F9)
                                      : Colors.white54,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  published ? 'Online' : 'Privado',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  onSelected: (v) async {
                                    if (v == 'publish') {
                                      await CreatorService.publishExisting(doc.id);
                                    }
                                    if (v == 'hide') {
                                      await CreatorService.unpublish(doc.id);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    if (!published)
                                      const PopupMenuItem(
                                        value: 'publish',
                                        child: Text('Publicar'),
                                      ),
                                    if (published)
                                      const PopupMenuItem(
                                        value: 'hide',
                                        child: Text('Tornar privado'),
                                      ),
                                  ],
                                  child: const Icon(Icons.more_horiz, size: 19),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d['prompt'] ?? 'Criação',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: publishing ? null : publishFromPhone,
            icon: publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(publishing ? 'Enviando...' : 'Publicar'),
          ),
        ),
      ],
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 58,
              color: Color(0xFFA78BFA),
            ),
            const SizedBox(height: 15),
            const Text(
              'Sua galeria online',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            const Text(
              'Crie ou publique imagens e vídeos do celular. Tudo fica salvo na nuvem.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: publishing ? null : publishFromPhone,
              icon: const Icon(Icons.add),
              label: const Text('Publicar agora'),
            ),
          ],
        ),
      ),
    );
  }
}
