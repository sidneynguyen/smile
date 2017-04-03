var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');
var session = require('express-session');
var passport = require('passport');
var FacebookTokenStrategy = require('passport-facebook-token');
var fileUpload = require('express-fileupload');
var mkdirp = require('mkdirp');
var mysql = require('mysql');
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'asdf',
  database : 'smilethursday'
});
var spawn = require('child_process').spawn;

connection.connect();

var app = express();

var auth = require('./routes/auth');
var api = require('./routes/api');

app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(fileUpload());
app.use(session({
  secret: 'I like warm hugs!!!!!',
  saveUninitialized: true,
  resave: true
}));
app.use(passport.initialize());
app.use(passport.session());

app.use('/auth', auth);
app.use('/api', api);

app.get('/test', function(req, res) {
  var process = spawn('python',["./verifyFace.py", '1']);
  process.stdout.on('data', function (data) {
    console.log(data);
    res.json({data: data.toString('utf8')[0]});
  });
});

const port = 3000;
app.listen(port, function() {
  console.log('Server started on port ' + port);
});