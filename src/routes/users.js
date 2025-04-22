const express = require('express');
const router = express.Router();

const fakeUsers = [
  { id: 1, name: 'Madeleine' },
  { id: 2, name: 'Una' }
];

router.get('/', (req, res) => {
  res.json(fakeUsers);
});

router.get('/:id', (req, res) => {
  const user = fakeUsers.find(u => u.id == req.params.id);
  if (user) {
    res.json(user);
  } else {
    res.status(404).send('User not found');
  }
});

module.exports = router;
