class Shop {
    constructor(id,fname,lname,name,email,emailVerified,adresse,position,siretNumber,tvaNumber,type,mainCategorie,description,phone,isPhoneVisible,ClickAndCollect,livraison,FCMToken,commandNb,premium,produits,count,colorStore,imgUrl ) {
        this.id = id;
        this.fname = fname;
        this.lname = lname;
        this.name = name;
        this.email = email;
        this.emailVerified = emailVerified;
        this.adresse = adresse;
        this.position = position;
        this.siretNumber = siretNumber;
        this.tvaNumber = tvaNumber;
        this.type = type;
        this.mainCategorie = mainCategorie;
        this.description   = description;
        this.phone = phone;
        this.isPhoneVisible = isPhoneVisible;
        this.ClickAndCollect = ClickAndCollect;
        this.livraison = livraison;
        this.FCMToken = FCMToken;
        this.commandNb = commandNb;
        this.premium = premium;
        this.produits = produits;
        this.count = count;
        this.colorStore = colorStore;
        this.imgUrl = imgUrl;      
    }
}

module.exports = Shop;