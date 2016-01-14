var request = require("request");
var qs = require('querystring');

function ask(user, service, text, callback) {
    var query = {
        user: user,
        service: service,
        q: text
    };
    request({
        url: "https://api.kari.xyz/chat/ask?" + qs.stringify(query),
        json: true
    }, function(error, response, body) {
        if (!error && response.statusCode == 200) {
            if("code" in body){
            	return callback(body);
            }
            return callback(null,body.message);
        }else{
        	return callback(error);
        }
    });
}

module.exports = ask;