const express = require("express");
const tasksRouter = require("./routes/tasks");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.use("/api/tasks", tasksRouter);

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// CD実行確認
// CD実行確認2
