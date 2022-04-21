'use strict';

const firebase = require('../db');
const Shop = require('../models/shop');
const Products = require('../models/products');
const firestore = firebase.firestore();


const addShop = async (req, res, next) => {
    try {
        const data = req.body;
        await firestore.collection('magasins').doc().set(data);
        res.send('Le magasin a bien été ajouté');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const getAllShops = async (req, res, next) => {
    try {
        const shops = await firestore.collection('magasins');
        const data = await shops.get();
        const shopsArray = [];
        if(data.empty) {
            res.status(404).send('Aucun magasin trouvé');
        }else {
            data.forEach(doc => {
                const shop = new Shop(
                    doc.data().id,
                    doc.data().Fname,
                    doc.data().Lname,
                    doc.data().name,
                    doc.data().email,
                    doc.data().emailVerified,
                    doc.data().adresse,
                    doc.data().position,
                    doc.data().siretNumber,
                    doc.data().tvaNumber,
                    doc.data().type,
                    doc.data().mainCategorie,
                    doc.data().description,
                    doc.data().phone,
                    doc.data().isPhoneVisibile,
                    doc.data().livraison,
                    doc.data().ClickAndCollect,
                    doc.data().livraison,
                    doc.data().FCMToken,
                    doc.data().commandNb,
                    doc.data().premium,
                    doc.data().produits,
                    doc.data().count,
                    doc.data().colorStore,
                    doc.data().imgUrl,
                );
                shopsArray.push(shop);
            });
            res.send(shopsArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const getAllProducts = async (req, res, next) => {
    try {
        const id = req.params.id;
        const products = await firestore.collection('magasins').doc(id).collection("produits");
        const data = await products.get();
        
        const productsArray = [];
        if(data.empty) {
            res.status(404).send('Aucun produit trouvé');
        }else {
            data.forEach(doc => {
                const product = new Products(
                    doc.data().id,
                    doc.data().nom,
                    doc.data().prix,
                    doc.data().description,
                    doc.data().images,
                    doc.data().categorie,
                    doc.data().quantite,
                    doc.data().reference,
                    doc.data().visible,
                );
                productsArray.push(product);
            });
            res.send(productsArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}


const getShop = async (req, res, next) => {
    try {
        const id = req.params.id;
        const shop = await firestore.collection('magasins').doc(id);
        const data = await shop.get();
        if(!data.exists) {
            res.status(404).send('Aucun magasin trouvé');
        }else {
            res.send(data.data());
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const updateShop = async (req, res, next) => {
    try {
        const id = req.params.id;    
        const colorStore = req.body.colorStore.substring(1); 
        const shop =  await firestore.collection('magasins').doc(id);
        await shop.update({
            fname: req.body.fname,
            lname: req.body.lname,
            name: req.body.companyName,
            adresse: req.body.autocomplete,
            email: req.body.email,
            phone: req.body.phone,
            description: req.body.description,
            type: req.body.companyType,
            ClickAndCollect: req.body.clickandcollect,
            livraison: req.body.livraison,
            isPhoneVisible: req.body.isPhoneVisible,
            mainCategorie: req.body.tagsCompany,
            siretNumber: req.body.siretNumber,
            tvaNumber: req.body.tvaNumber,
            colorStore: colorStore, 
            'position.latitude': req.body.latitude,
            'position.longitude': req.body.longitude,
        });    
        res.send("Le magasin a été  mis à jour");        
    } catch (error) {
        console.log(error) 
        res.status(400).send(error.message);
    }
} 

const deleteShop = async (req, res, next) => {
    try {
        const id = req.params.id;
         await firestore.collection('magasins').doc(id).delete();
        console.log(id)
        res.send("Le magasin a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const addProduct = async (req, res, next) => {
    try {
        console.log(req.body);
        const id = req.params.id;    
        const productName = req.body.productName;
        const description = req.body.description;
        const price =  req.body.price;
        const quantity = req.body.quantity;
        const reference = req.body.reference;
        const category = req.body.category;
        const visibility = req.body.visibility;
       

        await firestore.collection('magasins').doc(id).collection("produits").doc().set({
            nom: productName,
            prix: price,
            description: description,
            categorie: category,
            quantite: quantity,
            images:"", 
            reference: reference,
            visible: visibility,
        });
        res.send('Le produit a bien été ajouté');
    } catch (error) {
        res.status(400).send(error.message);
    }
}


const updateProduct = async (req, res, next) => {
    try {
        const id = req.params.id;    
        const idProduct = req.params.idProduct;
        const productName = req.body.productName;
        const description = req.body.description;
        const price =  req.body.price;
        const quantity = req.body.quantity;
        const reference = req.body.reference;
        const category = req.body.category;
        const visibility = req.body.visibility;

        await firestore.collection('magasins').doc(id).collection("produits").doc(idProduct).update({
            nom: productName,
            prix: price,
            description: description,
            categorie: category,
            quantite: quantity,
            reference: reference,
            visible: visibility,
        });
        res.send("Le magasin a été  mis à jour");        
    } catch (error) {
        console.log(error) 
        res.status(400).send(error.message);
    }
} 

const deleteProduct = async (req, res, next) => {
    try {
        const id = req.params.id;
        const idProduct = req.body.idProduct;
        console.log(idProduct);
        console.log(id);
        console.log(req.body);
        await firestore.collection('magasins').doc(id).collection('produits').doc(idProduct).delete();
        res.send("Le produit a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}


const getAllCommands = async (req, res, next) => {
    try {
        const id = req.params.id;
        console.log(id)
        const commandesCollection = await firestore.collection('commandes').get()
        console.log(commandesCollection.data);
        // const commands = await commandesCollection.where('users', 'array-contains', id).get();
        // console.log(commands.data);
        if(!data.exists) {
            res.status(404).send('Aucunes commandes trouvées');
        }else {
            res.send(data.data());
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}





module.exports = {
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
}