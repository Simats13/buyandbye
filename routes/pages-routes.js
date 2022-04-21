
const express = require('express');
const cookieParser = require('cookie-parser');
const csrf = require('csurf');
const axios = require('axios');

const firebase = require('../db');
const {registerView, loginView, homeView, dashboardView, entrepriseView, sessionLoginView } = require('../controllers/pagesController');

const router = express.Router();
const csrfProtection = csrf({
  cookie: true,
});

router.use(cookieParser());
// router.use(csrfMiddleware);

 
// router.all('*', (req, res, next) => {
//     res.cookie('XSRF-TOKEN', req.csrfToken());
//     next();
//   });
 
 


router.get('/', function (req, res) {  
    const sessionCookie = req.cookies.session || "";
    firebase.auth().verifySessionCookie(sessionCookie, true).then(() => {res.render("professional/pages/dashboard")}).catch((error)=>res.render("pages/login"))
  });
router.get('/inscription', registerView);
router.get('/connexion', loginView);
router.get('/home', homeView);   

router.get('/dashboard', function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then(() => {res.render("professional/pages/dashboard")}).catch((error)=>{res.redirect("/")})
});


router.get('/entreprise', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var data = await axios.get("http://localhost:8080/api/shops/" + uid);
    res.render("professional/pages/entreprise",{data:data.data});   
  }).catch((error)=>{res.redirect("/")})
}); 


router.get('/produits', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = await axios.get("http://localhost:8080/api/shops/" + uid);
    var products = await axios.get("http://localhost:8080/api/shops/" + uid+ "/products");         
    res.render("professional/pages/products",{products:products.data, shopInfos:shopInfos.data});   
  }).catch((error)=>{res.redirect("/")}) 
});
    
router.get('/commandes', csrfProtection, function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then( async (decodedToken) => {
    const uid = decodedToken.uid;
    var shopInfos = await axios.get("http://localhost:8080/api/shops/" + uid);
    var products = await axios.get("http://localhost:8080/api/shops/" + uid+ "/products");         
    res.render("professional/pages/commands",{products:products.data, shopInfos:shopInfos.data});   
  }).catch((error)=>{res.redirect("/")}) 
}); 
    

router.get('/messages', function (req, res) {
  const sessionCookie = req.cookies.session || "";
  firebase.auth().verifySessionCookie(sessionCookie, true).then((decodedToken) => {
    const uid = decodedToken.uid;    
    res.render("professional/pages/messages",{id:uid}) 
  }).catch((error)=>{res.redirect("/")})  
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