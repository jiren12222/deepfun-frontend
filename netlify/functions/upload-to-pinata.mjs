// Server-side only — PINATA_JWT is set as a Netlify environment variable,
// never shipped to the browser. Frontend sends a base64-encoded file here;
// this function uploads it to Pinata (IPFS) using the secret JWT and
// returns a public gateway URL.

export default async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  try {
    const { fileBase64, fileName, contentType } = await req.json();
    if (!fileBase64 || !fileName) {
      return new Response(JSON.stringify({ error: "Missing fileBase64 or fileName" }), { status: 400 });
    }

    const buffer = Buffer.from(fileBase64, "base64");
    const blob = new Blob([buffer], { type: contentType || "application/octet-stream" });

    const formData = new FormData();
    formData.append("file", blob, fileName);
    formData.append("network", "public");

    console.log("DEBUG: PINATA_JWT length =", (process.env.PINATA_JWT || "").length);
    console.log("DEBUG: PINATA_JWT first 20 chars =", (process.env.PINATA_JWT || "MISSING").slice(0, 20));

    const pinataRes = await fetch("https://uploads.pinata.cloud/v3/files", {
      method: "POST",
      headers: { Authorization: `Bearer ${process.env.PINATA_JWT}` },
      body: formData,
    });

    if (!pinataRes.ok) {
      const errText = await pinataRes.text();
      console.error("Pinata upload failed:", errText);
      return new Response(JSON.stringify({
        error: "Pinata upload failed",
        detail: errText,
        debug_jwt_length: (process.env.PINATA_JWT || "").length,
        debug_jwt_prefix: (process.env.PINATA_JWT || "MISSING").slice(0, 20),
        debug_gateway: process.env.PINATA_GATEWAY || "MISSING",
      }), { status: 502 });
    }

    const result = await pinataRes.json();
    const cid = result.data.cid;
    const gatewayUrl = `https://${process.env.PINATA_GATEWAY}/files/${cid}`;

    return new Response(JSON.stringify({ url: gatewayUrl, cid }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Upload function error:", err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
};

export const config = { path: "/api/upload-to-pinata" };
