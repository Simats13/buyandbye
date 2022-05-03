'use strict';

const firebase = require('../db');
const fieldValue = firebase.firestore.FieldValue; 
const testFirebase = require('firebase-admin');
const Shop = require('../models/shop');
const Products = require('../models/products');
const firestore = firebase.firestore();
const multer = require('multer')


const upload = multer({
    storage: multer.memoryStorage()
});

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
               
            
        
        const shop =  firestore.collection('magasins').doc(id);
        var data = JSON.parse(req.body.data);
        console.log(data.companyName);
        
        if(!req.file) {
            await shop.update({
                Fname: data.ownerFirstName,
                Lname: data.ownerLastName,
                name: data.companyName,
                adresse: data.autocomplete,
                email: data.email,
                phone: data.phone,
                description: data.description,
                ClickAndCollect: data.clickandcollect,
                livraison: data.livraison,
                isPhoneVisible: data.isPhoneVisible,
                mainCategorie: data.tagsCompany,
                siretNumber: data.siretNumber,
                tvaNumber: data.tvaNumber,
                colorStore: data.colorStore.substring(1),
                imgUrl:data.old_banniere, 
                'position.latitude': data.latitude,
                'position.longitude': data.longitude,
            });
           return res.status(200).json({success:"success"});
        } else {

            const blob = firebase.storage().bucket().file(`profile/${id}/banniere`); 
   

            const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/profile%2F${id}%2Fbanniere?alt=media`;
            
            const blobWriter = blob.createWriteStream({
                metadata: {
                    contentType: req.file.mimetype,
                }
            })  
            
            blobWriter.on('error', (err) => {
               
                console.log(err);
                return res.status(409).json({error:"Votre image n'a pas été envoyé"});
            })
            
            blobWriter.on('finish',async ()  => {
                await shop.update({
                    Fname: data.ownerFirstName,
                    Lname: data.ownerLastName,
                    name: data.companyName,
                    adresse: data.autocomplete,
                    email: data.email,
                    phone: data.phone,
                    description: data.description,
                    ClickAndCollect: data.clickandcollect,
                    livraison: data.livraison,
                    isPhoneVisible: data.isPhoneVisible,
                    mainCategorie: data.tagsCompany,
                    siretNumber: data.siretNumber,
                    tvaNumber: data.tvaNumber,
                    colorStore: data.colorStore.substring(1),
                    imgUrl: downloadUrl, 
                    'position.latitude': data.latitude,
                    'position.longitude': data.longitude,
                });  
               return res.status(200).json({success:"success"});
                // res.redirect('/entreprise/'); 
            })
            
            blobWriter.end(req.file.buffer);
        }
        // res.send("Le magasin a été  mis à jour");        
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
        const id = req.params.id;    
        const productName = req.body.productName;
        const description = req.body.description;
        const price =  parseFloat(req.body.price);
        const quantity = req.body.quantity;
        const reference = req.body.reference;
        const category = req.body.category;
        const visibility = req.body.visibility;
        const docRef =  await firestore.collection('magasins').doc(id).collection("produits").doc();
        const idProduct = docRef.id;

        var data = {
            id: idProduct,
            nom: productName,
            prix: price,
            description: description,
            categorie: category,
            quantite: quantity,
            images:"", 
            reference: reference,
            visible: visibility,
        };

        await docRef.set(data);

        await firestore.collection('magasins').doc(id).update({
            produits: fieldValue.arrayUnion({
                id: idProduct,
                nom: productName,
            }),
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
        const price =  parseFloat(req.body.price);
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

        console.log("test")
       

        var array = [];
        var request = await firestore.collection('magasins').doc(id).get();
      
        request.data().produits.forEach(function(item) {
            array.push(item);
        });

        var found = array.find(product => product.id === idProduct);
        // console.log(found)

        await firestore.collection('magasins').doc(id).update({
            produits: testFirebase.firestore.FieldValue.arrayRemove(found),
        });
        found.nom = productName;

        await firestore.collection('magasins').doc(id).update({
            produits: testFirebase.firestore.FieldValue.arrayUnion(found),
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
        await firestore.collection('magasins').doc(id).collection('produits').doc(idProduct).delete();
        var array = [];
        var request = await firestore.collection('magasins').doc(id).get();
      
        request.data().produits.forEach(function(item) {
            array.push(item);
        });

        var found = array.find(product => product.id === idProduct);
        

        await firestore.collection('magasins').doc(id).update({
            produits: testFirebase.firestore.FieldValue.arrayRemove(found),
        });
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