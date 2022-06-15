class Chats{
    constructor(id, users, lastMessage, messages, timestamp){
        this.id = id;
        this.users = users;
        this.lastMessage = lastMessage;
        this.messages = messages;
        this.timestamp = timestamp;
    }
}

module.exports = Chats;