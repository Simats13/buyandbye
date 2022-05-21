class User {
    constructor(id, firstName, lastName, emailVerified, FCMToken,admin,customerId,email,firstConnection,loved,phone,providers ) {
            this.id = id;
            this.firstName = firstName;
            this.lastName = lastName;
            this.emailVerified = emailVerified;
            this.FCMToken = FCMToken;
            this.admin = admin;
            this.customerId = customerId;
            this.email = email;
            this.firstConnection = firstConnection;
            this.loved = loved;
            this.phone = phone;
            this.providers = providers;
    }
}

module.exports = User;