import { PrismaClient } from "@prisma/client";

export const prisma = new PrismaClient();

export async function connectDB() {
    console.log("🟡 [DB] Iniciando conexão Prisma...");

    const { DB_URL } = process.env;

    console.log("📦 DB_URL existe?", !!DB_URL);

    if (!DB_URL) {
        console.error("❌ DB_URL não encontrada no .env");
        throw new Error("DB_URL is not defined");
    }

    try {
        console.log("🟡 [DB] Tentando conectar Prisma...");
        await prisma.$connect();
        console.log("🟢 [DB] Prisma conectado com sucesso");

    } catch (error) {
        console.error("🔥 [DB] ERRO PRISMA CONNECT:");
        console.error(error);

        // ⚠️ IMPORTANTE: NÃO matar processo agora
        console.log("⚠️ [DB] Falha de conexão - mantendo processo vivo para debug");

        throw error;
    }
}