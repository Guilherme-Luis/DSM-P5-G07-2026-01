import express from "express";
import cors from "cors";
import routes from "./routes/index.js";
import { swaggerDocs } from "./config/swagger.js";

const app = express();
const { NODE_ENV } = process.env;

console.log("🚀 App.js carregado");
console.log("📦 NODE_ENV:", NODE_ENV);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

console.log("🟡 Registrando rotas base...");
app.use(`/${NODE_ENV}/api`, routes);

console.log("🟡 Inicializando Swagger...");
swaggerDocs(app);

// =====================
// HEALTH CHECK DEBUG
// =====================
app.get(`/`, (req, res) => {
    console.log("📡 GET / health check chamado");

    res.json({
        service: `pi-services-api`,
        status: `running`,
        apiRoot: `${NODE_ENV}/api`,
        docs: `/${NODE_ENV}/api/docs`,
    });
});

// =====================
// ERROR HANDLER DEBUG
// =====================
app.use((err, req, res, next) => {
    console.error("🔥 EXPRESS ERROR HANDLER:");
    console.error(err);

    res.status(err.status || 500).json({
        message: err.message || "Internal Server Error",
    });
});

export default app;