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
    getAllCommands,
    getChats,
    getMessages,
    getChatsUsers,
    addMessage,
    
} = require('../controllers/shopController');

const router = express.Router();
const multer = require('multer');

const upload = multer({
    storage: multer.memoryStorage()
})
    


router.post('/shops', addShop);
router.get('/shops', getAllShops);
router.get('/shops/:id', getShop);
router.patch('/shops/:id',upload.single('banniere'), updateShop); 
router.delete('/shops/:id', deleteShop);
  
router.get('/shops/:id/products', getAllProducts);
router.post('/shops/:id/products/:idProduct/edit',upload.single('new_image'),updateProduct);
router.post('/shops/:id/products/:idProduct/delete',deleteProduct);
router.post('/shops/:id/products/add',upload.single('add_image'),addProduct); 

router.get('/chat/user/:id',getChats);
router.get('/chat/user/:id/messages',getMessages);
router.get('/chat/user/:id/users',getChatsUsers);
router.post('/chat/:id', addMessage);

router.get('/shops/:id/commands',getAllCommands);


module.exports={
    routes:router
}