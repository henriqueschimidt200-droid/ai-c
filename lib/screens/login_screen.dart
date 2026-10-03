import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool firebaseUnavailable;
  const LoginScreen({super.key, this.firebaseUnavailable = false});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email=TextEditingController(), password=TextEditingController();
  bool register=false, loading=false, obscure=true;

  Future<void> action(Future Function() fn) async {
    setState(()=>loading=true);
    try { await fn(); }
    catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível continuar: $e')));
    } finally { if(mounted) setState(()=>loading=false); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children:[
        Positioned(top:-160,right:-110,child:_orb(330,const Color(0xFF7C3AED))),
        Positioned(bottom:-180,left:-130,child:_orb(350,const Color(0xFF2563EB))),
        SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal:24,vertical:36),
          child: ConstrainedBox(constraints:const BoxConstraints(maxWidth:470),
            child: Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              Container(
                width:82,height:82,alignment:Alignment.center,
                decoration:BoxDecoration(
                  gradient:const LinearGradient(colors:[Color(0xFF8B5CF6),Color(0xFFEC4899)]),
                  borderRadius:BorderRadius.circular(28),
                  boxShadow:[BoxShadow(color:const Color(0xFF8B5CF6).withOpacity(.35),blurRadius:35)]
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets_ai_icon.png', width: 64, height: 64))),
              const SizedBox(height:26),
              const Text('Crie sem limites.',style:TextStyle(fontSize:40,fontWeight:FontWeight.w900,height:1.0)),
              const SizedBox(height:10),
              Text('Imagens, vídeos e ideias transformados por IA em um só lugar.',
                style:TextStyle(fontSize:16,color:Colors.white.withOpacity(.62),height:1.45)),
              const SizedBox(height:32),
              if (widget.firebaseUnavailable) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: const Text('Modo de demonstração: o app abriu normalmente. Configure o Firebase para ativar login e sincronização na nuvem.', style: TextStyle(fontSize: 13, height: 1.35)),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 17), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen())),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Entrar no modo demonstração'),
                ),
                const SizedBox(height: 18),
              ],
              FilledButton.icon(
                style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:17),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
                onPressed:loading?null:()=>action(()=>AuthService.signInWithGoogle()),
                icon:const Icon(Icons.g_mobiledata,size:28),label:const Text('Continuar com Google')),
              const SizedBox(height:18),
              Row(children:[Expanded(child:Divider(color:Colors.white.withOpacity(.1))),Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Text('ou',style:TextStyle(color:Colors.white.withOpacity(.45)))),Expanded(child:Divider(color:Colors.white.withOpacity(.1)))]),
              const SizedBox(height:18),
              TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(prefixIcon:Icon(Icons.mail_outline),labelText:'E-mail')),
              const SizedBox(height:12),
              TextField(controller:password,obscureText:obscure,decoration:InputDecoration(prefixIcon:const Icon(Icons.lock_outline),labelText:'Senha',suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
              const SizedBox(height:16),
              FilledButton(
                style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:17),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),
                onPressed:loading?null:()=>action(()=>register?AuthService.registerEmail(email.text,password.text):AuthService.signInEmail(email.text,password.text)),
                child:Text(register?'Criar minha conta':'Entrar')),
              TextButton(onPressed:loading?null:()=>setState(()=>register=!register),child:Text(register?'Já tenho uma conta':'Criar uma conta grátis')),
              if(loading) const Padding(padding:EdgeInsets.only(top:12),child:LinearProgressIndicator()),
            ]))),
        ))
      ])
    );
  }
  Widget _orb(double s,Color c)=>Container(width:s,height:s,decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[c.withOpacity(.18),Colors.transparent])));
}
