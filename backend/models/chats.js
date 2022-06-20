class Chats{
    constructor(id, users, lastMessage, timestamp, messages){
        this.id = id;
        this.users = users;
        this.lastMessage = lastMessage;
        this.timestamp = timestamp;
        this.messages = messages;

    }
}

module.exports = Chats;