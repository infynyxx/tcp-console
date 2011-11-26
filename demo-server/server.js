var net = require('net');

if (process.argv.length !== 3) {
    console.log("Please specify port!");
    process.exit(1);
}

var port = parseInt(process.argv[2]);

if (isNaN(port)) {
    console.log("Invalid Port");
    process.exit(1);
}

var server = net.createServer(function(socket) {
    socket.on('data', function(data) {
        console.log("Recieved: " + data.toString());
        var random = parseInt(Math.random() * 1000);
        var data = {'desc': 'This is test server running on port: ' + port, random: random};
        socket.write(JSON.stringify(data) + "\r\n");
    });
});

server.listen(port, 'localhost', function() {
    console.log("Server started on port: " + port);
});

