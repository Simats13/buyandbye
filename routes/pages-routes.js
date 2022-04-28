
const express = require('express');
const cookieParser = require('cookie-parser');
const csrf = require('csurf');
const axios = require('axios');
const https = require('https');
const fs = require('fs');
const firebase = require('../db');
const {registerView, loginView, homeView, dashboardView, entrepriseView, sessionLoginView } = require('../controllers/pagesController');

const router = express.Router();
const csrfProtection = csrf({
  cookie: true,
});

router.use(cookieParser());

var httpsAgent = new https.Agent({
  rejectUnauthorized: false, // (NOTE: this will disable client verification)
  cert: fs.readFileSync("./certs/certs.pem"),
  key: fs.readFileSync("./certs/privateKey.pem"),
  ca: fs.readFileSync("./certs/ca.pem"),
})
 

router.get('/', function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then(async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = instance.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid,{ agent: httpsAgent });
    res.render("professional/pages/dashboard",{shopInfos:shopInfos.data})
  }).catch((error)=>{console.log(error);res.render("pages/login");})
});

router.get('/inscription', registerView);
router.get('/connexion', loginView);
// router.get('/home', homeView);   

router.get('/dashboard', function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then(async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = instance.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid,{ agent: httpsAgent });
    res.render("professional/pages/dashboard",{shopInfos:shopInfos.data})
  }).catch((error)=>{console.log(error);res.redirect("/")})
});
 

router.get('/entreprise', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = await axios.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid);
    res.render("professional/pages/entreprise",{shopInfos:shopInfos.data});   
  }).catch((error)=>{res.redirect("/")})
}); 


router.get('/produits', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = await axios.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid);
    var products = await axios.get(req.protocol + '://' + req.get('host')  +"/api/shops/" + uid+ "/products");         
    res.render("professional/pages/products",{products:products.data, shopInfos:shopInfos.data});   
  }).catch((error)=>{res.redirect("/")}) 
});
       
router.get('/commandes', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = await axios.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid);
    var products = await axios.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid+ "/products");         
    res.render("professional/pages/commands",{products:products.data, shopInfos:shopInfos.data});   
  }).catch((error)=>{
    console.log(req.hostname);
    res.redirect("/")}) 
}); 
    

router.get('/messages', function (req, res) { 
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then(async (decodedToken) => {
    const uid = decodedToken.uid;    
    var shopInfos = await axios.get(req.protocol + '://' + req.get('host')  + "/api/shops/" + uid, { agent: httpsAgent });
    res.render("professional/pages/messages",{id:uid,shopInfos:shopInfos.data});
  }).catch((error)=>{res.redirect("/")});   
});
router.post('/edit',function(req,res){
  res.redirect('/dashboard'); 
});
   
router.get('/logout', (req, res) => {
    res.clearCookie('session');
    res.redirect('/');
  });    
                  
router.post('/sessionLogin', sessionLoginView ) 
module.exports = router;