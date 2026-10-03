# AI Creator

App Flutter de criação com IA + biblioteca + feed público + login.

## 1. Instalar dependências

```bash
flutter pub get
```

## 2. Configurar Firebase

Crie um projeto no Firebase e ative:

- Authentication > Google
- Authentication > Email/Password
- Firestore Database
- Storage

Instale o FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Depois, na raiz do projeto:

```bash
flutterfire configure
```

Isso gera automaticamente `lib/firebase_options.dart`.

No Firebase Authentication, configure o provedor Google e os identificadores necessários para Android/iOS.

## 3. Regras

Publique `firestore.rules` e `storage.rules` no Firebase.

## 4. Rodar

```bash
flutter run
```

## 5. Conectar geração real de IA

Não coloque chaves de APIs de IA dentro do aplicativo.

Use um backend/Cloud Function:

App -> Backend -> provedor de imagem/vídeo -> Storage -> App

O backend deve validar o usuário, controlar créditos, limitar abuso e salvar o resultado.

## Próximas telas recomendadas

- Perfil público
- Curtidas/comentários
- Publicar/editar publicação
- Gerenciador de créditos
- Histórico de gerações
- Upload de imagem
- Imagem -> vídeo
- Edição por IA
- Moderação e denúncia
- Notificações
