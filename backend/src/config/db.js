import { PrismaClient } from "@prisma/client";

export const prisma = new PrismaClient();

export async function connectDB() {
    const { DB_URL } = process.env;
    
    if (!DB_URL) {
        throw new Error("DB_URL is not defined in environment variables");
    }
    try{
        await prisma.$connect();
        //console.log(`Prisma connected to MongoDB successfully`);
    } catch (error) {
        console.error(`Prisma connection error: ${error.message}`);
        process.exit(1);
    }
}
