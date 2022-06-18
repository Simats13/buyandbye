class Chats{
    constructor(id, users, lastMessage, timestamp){
        this.id = id;
        this.users = users;
        this.lastMessage = lastMessage;
        this.timestamp = timestamp;
    }
}

module.exports = Chats;