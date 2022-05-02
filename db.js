const firebase = require('firebase-admin');
const config = require('./config');
// import serviceAccount from '../serviceKey.json';
const serviceAccount = require( './serviceKey.json');
const db = firebase.initializeApp({
    credential: firebase.credential.cert(serviceAccount),
    databaseURL: "https://oficium-11bf9-default-rtdb.firebaseio.com",
    storageBucket: "oficium-11bf9.appspot.com",
});

module.exports = db;