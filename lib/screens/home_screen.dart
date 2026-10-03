import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/credits_service.dart';
import 'create_screen.dart';
import 'feed_screen.dart';
import 'library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  int credits = 100;
  bool unlimited = false;
  final pages = const [CreateScreen(), FeedScreen(), LibraryScreen()];
  final titles = const ['Studio', 'Explorar', 'Minha biblioteca'];

  @override void initState() { super.initState(); _loadCredits(); }
  Future<void> _loadCredits() async { final u = await CreditsService.isUnlimited(); final c = await CreditsService.getCredits(); if (mounted) setState(() { unlimited = u; credits = c; }); }

  Future<void> _redeemCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('Código de créditos'),
      content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Digite seu código', prefixIcon: Icon(Icons.key_outlined))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Ativar'))],
    ));
    if (code == null) return;
    final ok = await CreditsService.redeem(code);
    if (ok) { await _loadCredits(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('∞ Créditos infinitos ativados!'))); }
    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código inválido.')));
  }

  @override Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets_ai_icon.png', width: 42, height: 42)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titles[index], style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), Text('AI Creator', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.42)))])]),
        actions: [
          InkWell(onTap: _redeemCode, borderRadius: BorderRadius.circular(22), child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF171827), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(.25))), child: Row(children: [const Icon(Icons.bolt, size: 16, color: Color(0xFFFBBF24)), const SizedBox(width: 5), Text(unlimited ? '∞' : '$credits', style: const TextStyle(fontWeight: FontWeight.w800))]))),
          PopupMenuButton<String>(onSelected: (v) { if (v == 'credits') _redeemCode(); if (v == 'logout') AuthService.signOut(); }, itemBuilder: (_) => [const PopupMenuItem(value: 'credits', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.bolt), title: Text('Código de créditos'))), const PopupMenuItem(value: 'logout', child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.logout), title: Text('Sair')))]),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(height: 78, selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Criar'),
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
        NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Biblioteca'),
      ]),
    );
  }
}
