const express = require('express');
const bodyParser = require("body-parser");
const {
    signInWithEmailAndPassword,
    logout,
} = require('../controllers/authController');

const router = express.Router();

router.post('/auth', signInWithEmailAndPassword);
router.post('/logout', logout);


// router.post('/auth',function(req,res){
//     var user_name = req.body.email;
//     var password = req.body.password;
//     console.log("User name = "+user_name+", password is "+password);
//     res.end("yes");
//     });

module.exports={
    routes:router
}