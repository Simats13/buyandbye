class Products{
    constructor(id, name, price, description, image, category, quantity, reference,visibility){
        this.id = id;
        this.name = name;
        this.price = price;
        this.description = description;
        this.image = image;
        this.category = category;
        this.quantity = quantity;
        this.reference = reference;
        this.visibility = visibility;
    }
}

module.exports = Products;