'use strict';

const firebase = require('../db');
const fieldValue = firebase.firestore.FieldValue; 
const adminFirebase = require('firebase-admin');
const Shop = require('../models/shop');
const Products = require('../models/products');
const firestore = firebase.firestore();
const multer = require('multer')
const axios = require('axios');
const Chats = require('../models/chats');
const Messages = require('../models/messages');
const NodeGeocoder = require('node-geocoder');
const config = require('../config');

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
        const data = JSON.parse(req.body.data);
        const options = {
            provider: 'google',
            httpAdapter: 'https', // Default
            apiKey: config.maps_api, // for Mapquest, OpenCage, Google Premier
            formatter: null // 'gpx', 'string', ...
          };
        const geocoder = NodeGeocoder(options);
        const geores = await geocoder.geocode(data.enterpriseAdress);
        if(!req.file) {
            await shop.update({
                name: data.enterpriseName,
                adresse: data.enterpriseAdress,
                email: data.emailEnterprise,
                phone: data.enterprisePhone,
                description: data.description,
                ClickAndCollect: data.clickAndCollect,
                livraison: data.delivery,
                isPhoneVisible: data.isPhoneVisible,
                siretNumber: data.siretNumber,
                tvaNumber: data.tvaNumber,
                mainCategorie: data.tagsEnterprise,
                colorStore: data.colorEnterprise,
                imgUrl:data.oldPhotoEnterprise, 
                'position.geopoint.latitude': geores[0].latitude,
                'position.geopoint.longitude': geores[0].longitude,
            });
           return res.status(200).json({status:"success", message:"Votre magasin a bien été modifié"});
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
                return res.status(409).json({status:"error", message:"Votre image n'a pas été envoyé"});
            })
            
            blobWriter.on('finish',async ()  => {
                await shop.update({
                    name: data.enterpriseName,
                    adresse: data.enterpriseAdress,
                    email: data.emailEnterprise,
                    phone: data.enterprisePhone,
                    description: data.description,
                    ClickAndCollect: data.clickAndCollect,
                    livraison: data.delivery,
                    isPhoneVisible: data.isPhoneVisible,
                    siretNumber: data.siretNumber,
                    tvaNumber: data.tvaNumber,
                    mainCategorie: data.tagsEnterprise,
                    colorStore: data.colorEnterprise,
                    imgUrl: downloadUrl, 
                    'position.latitude': geores[0].latitude,
                    'position.longitude': geores[0].longitude,
                });  
               return res.status(200).json({status:"success", message:"Votre magasin a bien été modifié"});
                // res.redirect('/entreprise/'); 
            });
            
            blobWriter.end(req.file.buffer);
        }     
    } catch (error) {
        console.log(error) 
        res.status(400).json({status:"error", message:"Votre magasin n'a pas été modifié"});
    }
} 

const deleteShop = async (req, res, next) => {
    try {
        const id = req.params.id;
         await firestore.collection('magasins').doc(id).delete();
        res.send("Le magasin a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const addProduct = async (req, res, next) => {
    try {
        const id = req.params.id;   
        const docRef = firestore.collection('magasins').doc(id).collection("produits").doc();
        var data = req.body;
        console.log(data);
        var images = [];
        images.push("https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/assets%2FNo_image_available.svg.png");

        if(!req.file) {
            await docRef.set({
                id: docRef.id,
                nom: data.productName,
                prix: parseFloat(data.productPrice),
                description: data.productDescription,
                categorie: data.productCategory,
                quantite: data.productQuantity,
                images:images, 
                reference: data.productReference,
                weight: data.productWeight,
                discount: data.productDiscount,
                visible: data.productVisibility,
                brand: data.productBrand,
            });
            await firestore.collection('magasins').doc(id).update({
                produits: adminFirebase.firestore.FieldValue.arrayUnion({
                    id: docRef.id,
                    nom: data.productName,
                    categorie:data.productCategory,
                }),
            });

            // return res.status(200).json({
            //     id:id,
            //     idProduct: docRef.id,
            //     nom: data.productName,
            //     prix: parseFloat(data.price),
            //     description: data.description,
            //     categorie: data.category,
            //     quantite: data.quantity,
            //     images:images, 
            //     reference: data.reference,
            //     visible: data.visibility,
            //  });
        } else {
            const blob = firebase.storage().bucket().file(`products/${id}/${docRef.id}/1`); 
            const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/products%2F${id}%2F${docRef.id}%2F1?alt=media`;
            const blobWriter = blob.createWriteStream({
                metadata: {
                    contentType: req.file.mimetype,
                }
            })  
            blobWriter.on('error', (err) => {
                console.log(err);
                return res.status(409).json({error:"Votre image n'a pas été envoyé"});
            })

            var images = [];
            images.push(downloadUrl);
            blobWriter.on('finish',async ()  => {
                await docRef.set({
                    id: docRef.id,
                    nom: data.productName,
                    prix: parseFloat(data.price),
                    description: data.description,
                    categorie: data.category,
                    quantite: data.quantity,
                    images: images, 
                    reference: data.reference,
                    visible: data.visibility,
                });
        
                await firestore.collection('magasins').doc(id).update({
                    produits: adminFirebase.firestore.FieldValue.arrayUnion({
                        id: docRef.id,
                        nom: data.productName,
                        categorie:data.category,
                    }),
                });
                return res.status(200).json({
                    id:id,
                    idProduct: docRef.id,
                    nom: data.productName,
                    prix: parseFloat(data.price),
                    description: data.description,
                    categorie: data.category,
                    quantite: data.quantity,
                    images:images, 
                    reference: data.reference,
                    visible: data.visibility,
                 });
            });
            
            blobWriter.end(req.file.buffer);
        }

    } catch (error) {
        res.status(400).send(error.message);
    }
}

 
const updateProduct = async (req, res, next) => {
    try {
        const id = req.params.id;    
        const idProduct = req.params.idProduct;
        var data = req.body;
        console.log(req.body);

        var images = [];
        images.push(data.currentImageInput);
        

        if(!req.file) {
            await firestore.collection('magasins').doc(id).collection("produits").doc(idProduct).update({
                nom: data.productName,
                prix: parseFloat(data.productPrice),
                description: data.productDescription,
                categorie: data.productCategory,
                reference: data.productReference,
                quantite: parseFloat(data.productQuantity),
                discount: parseFloat(data.productDiscount),
                brand: data.productBrand,
                weight: parseFloat(data.productWeight),
                visible: data.productVisibility,
                // images:images,
            });
           
    
            var array = [];
            var request = await firestore.collection('magasins').doc(id).get();
          
            request.data().produits.forEach(function(item) {
                array.push(item);
            });
    
            var found = array.find(product => product.id === idProduct);
       
    
            await firestore.collection('magasins').doc(id).update({
                produits: adminFirebase.firestore.FieldValue.arrayRemove(found),
            });
            found.nom = data.productName;
            found.categorie = data.productCategory;
    
            await firestore.collection('magasins').doc(id).update({
                produits: adminFirebase.firestore.FieldValue.arrayUnion(found),
            });

  
           return res.status(200).json({
                sucess: 'Produit modifié avec succès',
            });
        } else {
            const blob = firebase.storage().bucket().file(`products/${id}/${idProduct}/1`); 
            const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/products%2F${id}%2F${idProduct}%2F1?alt=media`;
            const blobWriter = blob.createWriteStream({
                metadata: {
                    contentType: req.file.mimetype,
                }
            })  
            blobWriter.on('error', (err) => {
                console.log(err);
                return res.status(409).json({error:"Votre image n'a pas été envoyé"});
            })

            var images = [];
            images.push(downloadUrl);
            blobWriter.on('finish',async ()  => {
                await firestore.collection('magasins').doc(id).collection("produits").doc(idProduct).update({
                    nom: data.productName,
                    prix: parseFloat(data.price),
                    description: data.description,
                    categorie: data.category,
                    quantite: data.quantity,
                    reference: data.reference,
                    visible: data.visibility,
                    images:images,
                });
               
        
                var array = [];
                var request = await firestore.collection('magasins').doc(id).get();
              
                request.data().produits.forEach(function(item) {
                    array.push(item);
                });
        
                var found = array.find(product => product.id === idProduct);
        
                await firestore.collection('magasins').doc(id).update({
                    produits: adminFirebase.firestore.FieldValue.arrayRemove(found),
                });
                found.nom = data.productName;
                found.categorie = data.category;
        
                await firestore.collection('magasins').doc(id).update({
                    produits: adminFirebase.firestore.FieldValue.arrayUnion(found),
                });
                return res.status(200).json({
                    nom: data.productName,
                    prix: parseFloat(data.price),
                    description: data.description,
                    categorie: data.category,
                    quantite: data.quantity,
                    reference: data.reference,
                    visible: data.visibility,
                    images:images,
                 });
            });
            
            blobWriter.end(req.file.buffer);
        }
        

      
            
    } catch (error) {
        console.log(error) 
        res.status(400).send(error.message);
    }
} 

const deleteProduct = async (req, res, next) => {
    try {
        const id = req.params.id;
        const idProduct = req.params.idProduct;
        await firestore.collection('magasins').doc(id).collection('produits').doc(idProduct).delete();
         await firebase.storage().bucket().deleteFiles({
             prefix: `products/${id}/${idProduct}/`
         });
        var array = [];
        var request = await firestore.collection('magasins').doc(id).get();
      
        request.data().produits.forEach(function(item) {
            array.push(item);
        });

        var found = array.find(product => product.id === idProduct);
        

        await firestore.collection('magasins').doc(id).update({
            produits: adminFirebase.firestore.FieldValue.arrayRemove(found),
        });
        res.send("Le produit a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}



const getChats = async (req, res, next) => {
    try {
        const id = req.params.id;
        const chats = await firestore.collection('commonData').where('users', 'array-contains', id).orderBy('timestamp', 'desc').get();
        const chatsArray = [];
        const allChats = [];

        if(chats.empty) {
            res.status(404).send('Aucune conversation trouvée');
        }else {
            chats.forEach(doc => {
                const chat = new Chats(
                    doc.ref.id,
                    doc.data().users,
                    doc.data().lastMessage,
                    doc.data().timestamp,
                );
                chatsArray.push(chat);         
                // test1.push(chat);
            });
            
            for (const idChat of chatsArray){
                await axios.get(`http://localhost:81/api/chat/user/${idChat.id}/messages`).then((response) =>{
                    const chat = new Chats(
                        idChat.id,
                        idChat.users,
                        idChat.lastMessage,
                        idChat.timestamp,
                        response.data,
                    ); 
                    allChats.push(chat);
                });

                  
            }
            res.send(allChats);

            
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
};

const getMessages = async (req, res, next) => {
    try {
        const id = req.params.id;
        const chats = await firestore.collection('commonData').doc(id).collection('messages').orderBy('timestamp', 'asc').get();
        const messagesUsers = [];

        if(chats.empty) {
            res.status(404).send('Aucune conversation trouvée');
        }else {
            chats.forEach(doc => {
                    const messageData = new Messages(
                        doc.data().idFrom,
                        doc.data().idTo,
                        doc.data().isread,
                        doc.data().message,
                        doc.data().sentByClient,
                        doc.data().timestamp,
                        doc.data().type
                    );
                    messagesUsers.push(messageData);
            });
            res.send(messagesUsers);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const getChatsUsers = async (req, res, next) => {
    try {
        const id = req.params.id;
        const chats = await firestore.collection('commonData').where('users', 'array-contains', id).get();
        const chatsUsersArray = [];
        const userInfos = [];

        chats.forEach(doc => {
            chatsUsersArray.push({
                'lastMessage': doc.data().lastMessage,
                'timestamp': doc.data().timestamp,
                'id': doc.data().users[1]
            });
        });

        for (const idUser of chatsUsersArray){
            const users = await firestore.collection('users').doc(idUser.id).get();
            userInfos.push({
                'lastMessage': idUser.lastMessage,
                'timestamp': idUser.timestamp,
                'imgUrl': users.data().imgUrl,
                'name': users.data().fname + " " + users.data().lname,
                'id': users.data().id,
            });
        }

        res.send(userInfos);
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const addMessage = async (req, res, next) => {
    try{
        const id = req.params.id;
        const date = new Date();
        await firestore.collection('commonData').doc(id).collection('messages').add({
            idFrom: req.body.idFrom,
            idTo: req.body.idTo,
            message: req.body.message,
            isread: req.body.isread,
            sentByClient: req.body.sentByClient,
            type: req.body.type,
            timestamp: adminFirebase.firestore.Timestamp.fromDate(date),
        });
        await firestore.collection('commonData').doc(id).update({
            lastMessage: req.body.message,
            timestamp: adminFirebase.firestore.Timestamp.fromDate(date),
        });
        res.send('Message send');
    }catch (error) {
        res.status(400).send(error.message);
    }
};

const getAllCommands = async (req, res, next) => {
    try {
        const id = req.params.id;
        const commandesCollection = await firestore.collectionGroup('commands').where('sellerID', '==', id).get()
        const commands = [];
        commandesCollection.forEach(doc => {
            commands.push(doc.data());      
        });
        res.send(commands);
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
    getChats,
    getMessages,
    getChatsUsers,
    addMessage
}