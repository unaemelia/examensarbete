const express = require("express");
const _ = require("lodash");

const app = express();
app.get("/", (req, res) => {
  res.send("npm audit vulnerability test");
});
app.listen(3000, () => {
  console.log("App running on port 3000");
});
