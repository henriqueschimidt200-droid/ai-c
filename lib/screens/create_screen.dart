import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/creator_service.dart';
import '../services/credits_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final prompt = TextEditingController();
  String type = 'Imagem';
  bool busy = false;

  final examples = [
    'Um dragão colossal em uma cidade futurista',
    'Uma floresta mágica cinematográfica em 8K',
    'Retrato de um astronauta em Marte ao pôr do sol',
    'Uma cidade cyberpunk com chuva e néon',
  ];

  @override
  void dispose() {
    prompt.dispose();
    super.dispose();
  }

  Future<void> create() async {
    if (prompt.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva o que você quer criar.')),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final can = await CreditsService.spend();
      if (!can) {
        throw StateError('Você ficou sem créditos. Ative seu código de créditos.');
      }

      await CreatorService.saveProject(
        type: type,
        prompt: prompt.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projeto salvo com sucesso.')),
        );
        prompt.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        _hero(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'Criar com IA',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'STUDIO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC4B5FD),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        SegmentedButton<String>(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
          segments: const [
            ButtonSegment(
              value: 'Imagem',
              icon: Icon(Icons.image_outlined),
              label: Text('Imagem'),
            ),
            ButtonSegment(
              value: 'Vídeo',
              icon: Icon(Icons.movie_creation_outlined),
              label: Text('Vídeo'),
            ),
          ],
          selected: {type},
          onSelectionChanged: (v) => setState(() => type = v.first),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF11121E),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(.08)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(.07),
                blurRadius: 30,
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: prompt,
                maxLines: 7,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  hintText: 'Descreva sua ideia... Quanto mais detalhes, melhor.',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: busy ? null : create,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(busy ? 'Preparando...' : 'Gerar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Prompts em destaque',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples
              .map(
                (e) => ActionChip(
                  onPressed: () => setState(() => prompt.text = e),
                  avatar: const Icon(Icons.auto_awesome, size: 15),
                  label: Text(e),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _stat(Icons.image_outlined, 'Imagens', 'Alta qualidade'),
            const SizedBox(width: 10),
            _stat(Icons.movie_outlined, 'Vídeos', 'Pronto para publicar'),
            const SizedBox(width: 10),
            _stat(Icons.public_outlined, 'Social', 'Online'),
          ],
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String a, String b) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF11121E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFA78BFA)),
            const SizedBox(height: 8),
            Text(a, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              b,
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      height: 205,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF311568), Color(0xFF171A3A), Color(0xFF0E111F)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(.12),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(.12),
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Icon(
                Icons.auto_awesome,
                size: 82,
                color: const Color(0xFF67E8F9).withOpacity(.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '✦ AI CREATOR STUDIO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
              const Spacer(),
              const Text(
                'Transforme uma ideia\nem uma criação.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, height: 1.02),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie • Edite • Publique • Inspire',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
