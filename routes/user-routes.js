const express = require('express');
const {addUser, 
       getAllUsers, 
       getUser,
       updateUser,
       deleteUsers

      } = require('../controllers/userController');

const router = express.Router();

router.post('/users', addUser);
router.get('/users', getAllUsers);
router.get('/users/:id', getUser);
router.put('/users/:id', updateUser);
router.delete('/users/:id', deleteUsers);


module.exports = {
    routes: router
}