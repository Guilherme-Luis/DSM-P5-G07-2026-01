import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({
    path: path.resolve(__dirname, "../.env")
});

import express from "express";
import { connectDB } from "./config/db.js";
import { swaggerDocs } from "./config/swagger.js";
import routes from "./routes/index.js";

const app = express();
const { PORT, NODE_ENV } = process.env;

app.use(express.json());

async function startServer() {
    try {
        await connectDB();
        app.use(`/${NODE_ENV}/api`, routes);
        swaggerDocs(app);

        app.listen(PORT, () => {
            console.log(`Server running in ${NODE_ENV} mode on port ${PORT}`);
        });

    } catch (error) {
        console.error(`Failed to start server: ${error.message}`);
        process.exit(1);
    }
}

// Inicia o servidor
startServer();

export default app;