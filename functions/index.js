const { onRequest } = require("firebase-functions/v2/https");
const { defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { InferenceClient } = require("@huggingface/inference");

admin.initializeApp();

const HF_TOKEN = defineString("HF_TOKEN");
const HF_MODEL = defineString("HF_MODEL", {
  default: "black-forest-labs/FLUX.1-schnell",
});

function cors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

exports.generateImage = onRequest(
  { region: "us-central1", timeoutSeconds: 300, memory: "1GiB" },
  async (req, res) => {
    cors(res);
    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).json({ error: "POST only" });

    try {
      const auth = req.get("Authorization") || "";
      if (!auth.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Faça login no app primeiro." });
      }

      const decoded = await admin.auth().verifyIdToken(auth.substring(7));
      const prompt = String(req.body?.prompt || "").trim();

      if (!prompt) return res.status(400).json({ error: "Digite um prompt." });
      if (prompt.length > 1500) {
        return res.status(400).json({ error: "O prompt deve ter até 1500 caracteres." });
      }

      const client = new InferenceClient(HF_TOKEN.value());
      const image = await client.textToImage({
        provider: "auto",
        model: HF_MODEL.value(),
        inputs: prompt,
        parameters: { width: 1024, height: 1024 },
      });

      const buffer = Buffer.from(await image.arrayBuffer());
      const fileName =
        `users/${decoded.uid}/creations/${Date.now()}-${Math.random().toString(36).slice(2)}.png`;
      const file = admin.storage().bucket().file(fileName);

      await file.save(buffer, { metadata: { contentType: "image/png" } });

      const [url] = await file.getSignedUrl({
        action: "read",
        expires: "03-01-2035",
      });

      const doc = await admin.firestore().collection("projects").add({
        uid: decoded.uid,
        type: "Imagem",
        prompt,
        mediaUrl: url,
        published: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return res.json({ success: true, projectId: doc.id, imageUrl: url });
    } catch (error) {
      console.error(error);
      return res.status(500).json({
        error: error?.message || "Falha na geração da imagem."
      });
    }
  }
);