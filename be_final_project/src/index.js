import express from "express";
import db from "./utils/db.js";
import bodyParser from "body-parser";
import cors from "cors";
import transactionRoutes from "./routes/transcationRoutes.js";
import categoryRoutes from "./routes/categoryRoutes.js";

const app = express();
const port = 3002;

app.use(bodyParser.json());
app.use(cors());
app.use("/api/v1", transactionRoutes);
app.use("/api/v2", categoryRoutes);

db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to the MySQL database.");
});

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
