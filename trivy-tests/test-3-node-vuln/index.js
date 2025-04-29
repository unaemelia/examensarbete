const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello from a vulnerable Express app!");
});

app.listen(3000, () => {
  console.log("App running on http://localhost:3000");
});
