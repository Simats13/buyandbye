class Messages{
    constructor(idFrom, idTo, isRead, message, sentByClient, timestamp, type){
        this.idFrom = idFrom;
        this.idTo = idTo;
        this.isRead = isRead;
        this.message = message;
        this.sentByClient = sentByClient;
        this.timestamp = timestamp;
        this.type = type;
    }
}

module.exports = Messages;