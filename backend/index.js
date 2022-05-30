'use strict';
const express = require('express');
const cors = require('cors');
const config = require('./config');
const userRoutes = require('./routes/user-routes');
const shopRoutes = require('./routes/shop-routes');
const authRoutes = require('./routes/auth-routes');
const fs = require('fs');
const https = require('https');
const privateKey  = fs.readFileSync('./certs/privateKey.pem', 'utf8');
const certificate = fs.readFileSync('./certs/certs.pem', 'utf8');
const ca = fs.readFileSync('./certs/ca.pem', 'utf8');
const credentials = {key: privateKey, cert: certificate, ca:ca};
const app = express();


app.set('view engine', 'ejs');
app.use(express.static("public"));

app.use(express.json());
app.use(express.urlencoded({ extended: true })); 

            
// app.use('/' ,require('./routes/pages-routes'));
       
// app.use(express.json())
// app.use('/api', userRoutes.routes);
app.use('/api', cors(), shopRoutes.routes);
app.use('/api', authRoutes.routes);



 

//Routes


app.use(cors()); 
var httpsServer = https.createServer(credentials, app);

// httpsServer.listen(443);
app.listen(config.port, () => console.log('App is listening on url http://localhost:' + config.port));
 