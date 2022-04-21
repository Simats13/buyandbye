
const axios = require('axios');
const express = require('express');
const firebase = require("../db");



const registerView = (req, res) => {
    res.render("pages/register", {
    } );
}
// For View 
const loginView = (req, res) => {
    
    res.render("pages/login", {
    } );
}

const homeView = (req, res) => {

    res.render("pages/home", {
    } );
}

const dashboardView = (req, res) => {

    res.render("professional/pages/dashboard", {
    } );
}

const sessionLoginView = (req, res) => {
    const idToken = req.body.idToken.toString();
    const expiresIn = 60 * 60 * 24 * 5 * 1000;

    firebase.auth()
      .createSessionCookie(idToken, { expiresIn })
      .then(
        (sessionCookie) => {
          const options = { maxAge: expiresIn, httpOnly: true, secure: true };
          res.cookie('session', sessionCookie, options);
          res.end(JSON.stringify({ status: 'success' }));
        },
        (err) => {
          res.status(401).send('Request unauthorized');
        }
      );
}


async function getInfo(uid){
    var data = await axios.get("http://localhost:8080/api/shops/" + uid);
    return data;
}

const entrepriseView =  (req, res) => {
    const sessionCookie = req.cookies.session || '';

    firebase.auth()
      .verifySessionCookie(sessionCookie, true)
      .then((decodedToken) =>  {
        const uid = decodedToken.uid;
        let data =  getInfo(uid).then(async data => {
            res.render("professional/pages/entreprise",{data:data.data});
        });
        
        
      })
      .catch((err) => {
        console.log(err);
        res.redirect('/login');
        new Error('Cookies unknown');
      });
       
    // if (firebase.auth().currentUser !== null){
        // uid = firebase.auth().currentUser.uid;
        // const dataEnterprise = await axios.get("http://localhost:8080/api/shops/" + uid);
        // res.render("professional/pages/entreprise",{data:dataEnterprise.data});
    // }
        
     
}


module.exports =  {
    registerView,
    loginView,
    homeView,
    dashboardView,
    entrepriseView,
    sessionLoginView
};