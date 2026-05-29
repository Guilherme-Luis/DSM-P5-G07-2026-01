import dotenv from "dotenv";
dotenv.config();

import express from "express";
import { connectDB } from "./config/db.js";
import { swaggerDocs } from "./config/swagger.js";
import routes from "./routes/index.js";

const app = express();

const { PORT, NODE_ENV } = process.env;

app.use(express.json());

// ==============================
// 🧠 DEBUG GLOBAL DO PROCESSO
// ==============================
console.log("🚀 Boot do server iniciado");
console.log("📦 NODE_ENV:", NODE_ENV);
console.log("🔌 PORT:", PORT);

process.on("SIGINT", () => {
    console.log("🚨 SIGINT recebido (Ctrl+C ou PM2 stop/restart)");
});

process.on("SIGTERM", () => {
    console.log("🚨 SIGTERM recebido (kill ou PM2 restart)");
});

process.on("exit", (code) => {
    console.log("💀 Processo finalizando. Exit code:", code);
});

process.on("uncaughtException", (err) => {
    console.error("🔥 uncaughtException:", err);
});

process.on("unhandledRejection", (err) => {
    console.error("🔥 unhandledRejection:", err);
});

async function startServer() {
    try {
        console.log("🟡 Iniciando connectDB...");
        await connectDB();
        console.log("🟢 DB conectado com sucesso");

        console.log("🟡 Registrando rotas...");
        app.use(`/${NODE_ENV}/api`, routes);

        console.log("🟡 Inicializando Swagger...");
        swaggerDocs(app);

        app.listen(PORT, () => {
            console.log(`🟢 Server rodando em ${NODE_ENV} na porta ${PORT}`);
        });

    } catch (error) {
        console.error("🔥 ERRO NO START SERVER:");
        console.error(error);

        // 🔥 IMPORTANTE: temporariamente NÃO matar processo
        console.log("⚠️ NÃO finalizando processo para debug");
    }
}

startServer();

export default app;