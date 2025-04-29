const express = require('express');
const dotenv = require('dotenv');
const usersRoute = require('./routes/users');

dotenv.config();
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use('/api/users', usersRoute);

app.get('/', (req, res) => {
  res.send(`Welcome to ${process.env.APP_NAME}`);
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});

app.listen(port, () => {
  console.log(`${process.env.APP_NAME} is running on port ${port}`);
});
