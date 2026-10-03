# AI Creator — Comunidade Online

Esta versão adiciona uma comunidade online para imagens e vídeos.

## Publicação
- O botão **Publicar** na Biblioteca abre a galeria do celular.
- Imagens e vídeos são enviados para Firebase Storage.
- Um documento é criado no Firestore com autor, tipo, texto, URL e data.
- O conteúdo publicado aparece no feed de todos os usuários autenticados.
- O feed mostra imagens, reproduz vídeos e possui curtida.

## Créditos
O código especial `20661065` ativa créditos infinitos neste aplicativo.

**Nota:** como esse código está no APK, ele não deve ser tratado como segredo. Se a intenção for um código realmente privado, a validação deve ser movida para uma Cloud Function/backend.

## Firebase obrigatório para o online
1. Crie/configure um projeto Firebase.
2. Execute `flutterfire configure`.
3. Gere `lib/firebase_options.dart`.
4. Ative Authentication, Firestore e Storage.
5. Publique `firestore.rules` e `storage.rules`.
6. Para Google Login, configure o SHA-1/SHA-256 do app Android.

Sem Firebase configurado, o aplicativo ainda pode abrir, mas a comunidade online e os uploads não funcionarão.
