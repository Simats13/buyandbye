'use strict';
const express = require('express');
const cors = require('cors');
const config = require('./config');
const userRoutes = require('./routes/user-routes');
const shopRoutes = require('./routes/shop-routes');
const authRoutes = require('./routes/auth-routes');

const app = express();


app.set('view engine', 'ejs');
app.use(express.static("public"));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// app.use(express.json()); //this line activates the bodyparser middleware
// app.use(express.urlencoded({ extended: true }));


app.use('/' ,require('./routes/pages-routes'));

// app.use(express.json())
// app.use('/api', userRoutes.routes);
app.use('/api', shopRoutes.routes);
app.use('/api', authRoutes.routes);





//Routes


app.use(cors());

app.listen(config.port, () => console.log('App is listening on url http://localhost:' + config.port));
 