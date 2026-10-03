# 🔑 API DE IMAGEM — CONFIGURAÇÃO RÁPIDA

## 1. Pegue a chave

1. Entre em https://huggingface.co/
2. Crie uma conta ou faça login.
3. Abra https://huggingface.co/settings/tokens
4. Crie um token com acesso aos Inference Providers.
5. Copie a chave `hf_...`.

A disponibilidade de uso gratuito é limitada e pode mudar conforme a conta/provedor/modelo.

## 2. Onde colocar a chave

Na pasta `functions` existe:

`functions/.env.example`

Faça uma cópia e renomeie para:

`functions/.env`

Coloque:

`HF_TOKEN=hf_SUA_CHAVE_AQUI`

Deixe:

`HF_MODEL=black-forest-labs/FLUX.1-schnell`

### IMPORTANTE

NÃO coloque a chave em:
- `lib/`
- `main.dart`
- `pubspec.yaml`
- APK
- GitHub público

A chave fica somente no backend.

## 3. Firebase

No terminal, dentro do projeto:

`npm install -g firebase-tools`

`firebase login`

Depois:

`firebase use SEU_PROJETO_FIREBASE`

Entre em `functions`:

`cd functions`

`npm install`

Volte para a raiz e faça:

`firebase deploy --only functions`

O Firebase solicitará o valor de `HF_TOKEN` quando a configuração por parâmetros for aplicada.

## 4. Firebase no app

Execute:

`flutterfire configure`

Isso cria/atualiza `lib/firebase_options.dart`.

## 5. GitHub

O arquivo:

`.github/workflows/build-apk.yml`

já está pronto.

No GitHub:

**Actions → Build APK → Run workflow**

Depois abra a execução concluída e baixe:

**Artifacts → AI-Creator-APK**

## 6. Endpoint

Após o deploy, a Function terá uma URL parecida com:

`https://us-central1-SEU_PROJETO.cloudfunctions.net/generateImage`

Use essa URL no serviço de IA do Flutter.

Nunca coloque a `HF_TOKEN` nessa URL.

## 7. Se a chave vazar

Revogue a chave no Hugging Face e crie outra imediatamente.
