'use strict';

const firebase = require('../db');


const signInWithEmailAndPassword = async (req, res, next) => {
    try {
        const idToken = req.body.idToken.toString();

        const expiresIn = 60 * 60 * 24 * 5 * 1000;
      
        firebase.auth()
          .createSessionCookie(idToken, { expiresIn })
          .then(
            (sessionCookie) => {
              const options = { maxAge: expiresIn, httpOnly: true };
              res.cookie('session', sessionCookie, options);
              res.end("hello");
            },
            (err) => {
              res.status(401).send('Request unauthorized');
            }
          );    
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const logout = async (req, res, next) => {
    res.clearCookie('session');
    firebase.auth().signOut()
    return res.redirect('/')
};



module.exports = {
    signInWithEmailAndPassword,
    logout,
}