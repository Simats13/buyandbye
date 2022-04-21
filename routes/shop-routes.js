const express = require('express');
const {
    addShop,
    getAllShops,
    getShop,
    updateShop,
    deleteShop,
    getAllProducts,
    addProduct,
    deleteProduct,
    updateProduct,
    getAllCommands
    
} = require('../controllers/shopController');

const router = express.Router();




router.post('/shops', addShop);
router.get('/shops', getAllShops);
router.get('/shops/:id', getShop);
router.post('/shops/:id', updateShop); 
router.delete('/shops/:id', deleteShop);
  
router.get('/shops/:id/products', getAllProducts);
router.post('/shops/:id/products/:idProduct/edit',updateProduct);
router.post('/shops/:id/products/:idProduct/delete',deleteProduct);
router.post('/shops/:id/products/add',addProduct); 


router.get('/shops/:id/commands',getAllCommands);


module.exports={
    routes:router
}