'use strict';

const firebase = require('../db');
const fieldValue = firebase.firestore.FieldValue; 
const testFirebase = require('firebase-admin');
const Shop = require('../models/shop');
const Products = require('../models/products');
const firestore = firebase.firestore();
const multer = require('multer')
const axios = require('axios');
const Chats = require('../models/chats');
const Messages = require('../models/messages');

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
        if(!req.file) {
            await shop.update({
                name: req.body.enterpriseName,
                adresse: req.body.enterpriseAdress,
                email: req.body.emailEnterprise,
                phone: req.body.enterprisePhone,
                description: req.body.description,
                ClickAndCollect: req.body.clickAndCollect,
                livraison: req.body.delivery,
                isPhoneVisible: req.body.isPhoneVisible,
                siretNumber: req.body.siretNumber,
                tvaNumber: req.body.tvaNumber,
                // mainCategorie: data.tagsCompany,
                // colorStore: data.colorStore.substring(1),
                // imgUrl:data.old_banniere, 
                // 'position.latitude': data.latitude,
                // 'position.longitude': data.longitude,
            });
           return res.status(200).json({status:"error", message:"Votre magasin a bien été modifié"});
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
        console.log(id)
        res.send("Le magasin a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const addProduct = async (req, res, next) => {
    try {
        const id = req.params.id;
        console.log(id)    
        const docRef = firestore.collection('magasins').doc(id).collection("produits").doc();
        var data = JSON.parse(req.body.data);
        var images = [];
        images.push("https://firebasestorage.googleapis.com/v0/b/oficium-11bf9.appspot.com/o/assets%2FNo_image_available.svg.png");

        if(!req.file) {
            await docRef.set({
                id: docRef.id,
                nom: data.productName,
                prix: parseFloat(data.price),
                description: data.description,
                categorie: data.category,
                quantite: data.quantity,
                images:images, 
                reference: data.reference,
                visible: data.visibility,
            });
            await firestore.collection('magasins').doc(id).update({
                produits: testFirebase.firestore.FieldValue.arrayUnion({
                    id: data.idProduct,
                    nom: data.productName,
                    categorie:data.category,
                }),
            });
            var categoryInput;
            if(data.category === "Magasin") {
                 categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Electroménager" ? 'selected' : ''} >Electroménager</option>        <option ${data.category === "Jeux-Vidéos" ? 'selected' : ''} >Jeux-Vidéos</option>        <option ${data.category === "High-Tech" ? 'selected' : ''} >High-Tech</option>        <option ${data.category === "Alimentation" ? 'selected' : ''} >Alimentation</option>        <option ${data.category === "Vêtements" ? 'selected' : ''} >Vêtements</option>        <option ${data.category === "Films & Séries" ? 'selected' : ''} >Films & Séries</option>        <option ${data.category === "Chaussures" ? 'selected' : ''} >Chaussures</option>        <option ${data.category === "Bricolage" ? 'selected' : ''} >Bricolage</option>        <option ${data.category === "Montres & Bijoux" ? 'selected' : ''} >Montres & Bijoux</option>        <option ${data.category === "Téléphonie" ? 'selected' : ''} >Téléphonie</option>        <option ${data.category === "Restaurant" ? 'selected' : ''} >Restaurant</option>    </select></div>`;
            console.log(categoryInput);
                } else if(data.category === "Service") {
                 categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Menuiserie" ? 'selected' : ''} >Menuiserie</option>        <option ${data.category === "Plomberie" ? 'selected' : ''} >Plomberie</option>        <option ${data.category === "Piscine" ? 'selected' : ''} >Piscine</option>        <option ${data.category === "Meubles" ? 'selected' : ''} >Meubles</option>        <option ${data.category === "Vêtements" ? 'selected' : ''} >Vêtements</option>        <option ${data.category === "Gestion de patrimoine" ? 'selected' : ''} >Gestion de patrimoine</option>    </select></div>`;
            } else if(data.category === "Restaurant") {
                 categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Français" ? 'selected' : ''} >Français</option>        <option ${data.category === "Local" ? 'selected' : ''} >Local</option>        <option ${data.category === "Italien" ? 'selected' : ''} >Italien</option>        <option ${data.category === "Fast-Food" ? 'selected' : ''} >Fast-Food</option>        <option ${data.category === "Asiatique" ? 'selected' : ''} > Asiatique</option>        <option ${data.category === "Pizzeria" ? 'selected' : ''} >Pizzeria</option>    </select></div>`;
            } else if(data.category === "Santé") {
                 categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Pharmacie" ? 'selected' : ''} >Pharmacie</option>        <option ${data.category === "Aide à la personne" ? 'selected' : ''} >Aide à la personne</option>    </select></div>`;
            } else if(data.category === "Culture & Loisirs") {
                 categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Parc d'attraction" ? 'selected' : ''} >Parc d'attraction</option>        <option ${data.category === "Musée" ? 'selected' : ''} >Musée</option>        <option ${data.category === "Tourisme" ? 'selected' : ''} >Tourisme</option>    </select></div>`;    
            };
            console.log(categoryInput);
            return res.status(200).json({
                id:id,
                idProduct: docRef.id,
                nom: data.productName,
                prix: parseFloat(data.price),
                description: data.description,
                categorie: data.category,
                categorieInput: categoryInput,
                quantite: data.quantity,
                images:images, 
                reference: data.reference,
                visible: data.visibility,
             });
        } else {
            console.log("Id Product : "+docRef.id)
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
                    produits: testFirebase.firestore.FieldValue.arrayUnion({
                        id: docRef.id,
                        nom: data.productName,
                        categorie:data.category,
                    }),
                });
                var categoryInput = '';
                if(data.category === "Magasin") {
                
                     categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Electroménager" ? 'selected' : ''} >Electroménager</option>        <option ${data.category === "Jeux-Vidéos" ? 'selected' : ''} >Jeux-Vidéos</option>        <option ${data.category === "High-Tech" ? 'selected' : ''} >High-Tech</option>        <option ${data.category === "Alimentation" ? 'selected' : ''} >Alimentation</option>        <option ${data.category === "Vêtements" ? 'selected' : ''} >Vêtements</option>        <option ${data.category === "Films & Séries" ? 'selected' : ''} >Films & Séries</option>        <option ${data.category === "Chaussures" ? 'selected' : ''} >Chaussures</option>        <option ${data.category === "Bricolage" ? 'selected' : ''} >Bricolage</option>        <option ${data.category === "Montres & Bijoux" ? 'selected' : ''} >Montres & Bijoux</option>        <option ${data.category === "Téléphonie" ? 'selected' : ''} >Téléphonie</option>        <option ${data.category === "Restaurant" ? 'selected' : ''} >Restaurant</option>    </select></div>`;
    
                } else if(data.category === "Service") {
                     categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Menuiserie" ? 'selected' : ''} >Menuiserie</option>        <option ${data.category === "Plomberie" ? 'selected' : ''} >Plomberie</option>        <option ${data.category === "Piscine" ? 'selected' : ''} >Piscine</option>        <option ${data.category === "Meubles" ? 'selected' : ''} >Meubles</option>        <option ${data.category === "Vêtements" ? 'selected' : ''} >Vêtements</option>        <option ${data.category === "Gestion de patrimoine" ? 'selected' : ''} >Gestion de patrimoine</option>    </select></div>`;
                } else if(data.category === "Restaurant") {
                     categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Français" ? 'selected' : ''} >Français</option>        <option ${data.category === "Local" ? 'selected' : ''} >Local</option>        <option ${data.category === "Italien" ? 'selected' : ''} >Italien</option>        <option ${data.category === "Fast-Food" ? 'selected' : ''} >Fast-Food</option>        <option ${data.category === "Asiatique" ? 'selected' : ''} > Asiatique</option>        <option ${data.category === "Pizzeria" ? 'selected' : ''} >Pizzeria</option>    </select></div>`;
                } else if(data.category === "Santé") {
                     categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Pharmacie" ? 'selected' : ''} >Pharmacie</option>        <option ${data.category === "Aide à la personne" ? 'selected' : ''} >Aide à la personne</option>    </select></div>`;
                } else if(data.category === "Culture & Loisirs") {
                     categoryInput = `<div class="form-group">    <label class="mr-sm-2" for="category">Catégorie</label>    <select class="custom-select mr-sm-2" name="category" id="category" required>        <option selected disabled hidden>Veuillez choisir une catégorie</option>        <option ${data.category === "Parc d'attraction" ? 'selected' : ''} >Parc d'attraction</option>        <option ${data.category === "Musée" ? 'selected' : ''} >Musée</option>        <option ${data.category === "Tourisme" ? 'selected' : ''} >Tourisme</option>    </select></div>`;    
                };
                console.log(categoryInput);
                return res.status(200).json({
                    id:id,
                    idProduct: docRef.id,
                    nom: data.productName,
                    prix: parseFloat(data.price),
                    description: data.description,
                    categorie: data.category,
                    categorieInput: categoryInput,
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
        var data = JSON.parse(req.body.data);

        var images = [];
        images.push(data.currentImageInput);
        

        if(!req.file) {
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
                produits: testFirebase.firestore.FieldValue.arrayRemove(found),
            });
            found.nom = data.productName;
            found.categorie = data.category;
    
            await firestore.collection('magasins').doc(id).update({
                produits: testFirebase.firestore.FieldValue.arrayUnion(found),
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
                // console.log(found)
        
                await firestore.collection('magasins').doc(id).update({
                    produits: testFirebase.firestore.FieldValue.arrayRemove(found),
                });
                found.nom = data.productName;
                found.categorie = data.category;
        
                await firestore.collection('magasins').doc(id).update({
                    produits: testFirebase.firestore.FieldValue.arrayUnion(found),
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
        const idProduct = req.body.idProduct;
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


const getChats = async (req, res, next) => {
    try {
        const id = req.params.id;
        const chats = await firestore.collection('commonData').where('users', 'array-contains', id).get();
        const chatsArray = [];

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
            });
            res.send(chatsArray);

            
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
};

const getMessages = async (req, res, next) => {
    try {
        const id = req.params.id;
        const chats = await firestore.collection('commonData').doc(id).collection('messages').get();
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
            chatsUsersArray.push(doc.data().users[1]);
        });

        for (const idUser of chatsUsersArray){
            const users = await firestore.collection('users').doc(idUser).get();
            userInfos.push(users.data());
        }

        res.send(userInfos);
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
}