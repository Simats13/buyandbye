'use strict';

const firebase = require('../db');
const User = require('../models/user');
const firestore = firebase.firestore();


const addUser = async (req, res, next) => {
    try {
        const data = req.body;
        await firestore.collection('users').doc().set(data);
        res.send('L\'utilisateur a bien été ajouté');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const getAllUsers = async (req, res, next) => {
    try {
        const users = await firestore.collection('users');
        const data = await users.get();
        const usersArray = [];
        if(data.empty) {
            res.status(404).send('Aucun utilisateur trouvé');
        }else {
            data.forEach(doc => {
                const user = new User(
                    doc.id,
                    doc.data().fname,
                    doc.data().lname,
                    doc.data().emailVerified,
                    doc.data().FCMToken,
                    doc.data().admin,
                    doc.data().customerId,
                    doc.data().email,
                    doc.data().firstConnection,
                    doc.data().loved,
                    doc.data().phone,
                    doc.data().providers,
                );
                usersArray.push(user);
            });
            res.send(usersArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}



const getUser = async (req, res, next) => {
    try {
        const id = req.params.id;
        const user = await firestore.collection('users').doc(id);
        const data = await user.get();
        if(!data.exists) {
            res.status(404).send('Aucun utilisateur trouvé');
        }else {
            res.send(data.data());
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const updateUser = async (req, res, next) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const user =  await firestore.collection('users').doc(id);
        await user.update(data);
        res.send("L'utilisateur a été mis à jour");        
    } catch (error) {
        res.status(400).send(error.message);
    }
}

const deleteUsers = async (req, res, next) => {
    try {
        const id = req.params.id;
        await firestore.collection('users').doc(id).delete();
        res.send("L'utilisateur a bien été supprimé");
    } catch (error) {
        res.status(400).send(error.message);
    }
}

module.exports = {
    addUser,
    getAllUsers,
    getUser,
    updateUser,
    deleteUsers
}