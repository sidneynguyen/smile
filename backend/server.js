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
  password : 'Iwnsu0!',
  database : 'smilethursday'
});

connection.connect();
 
connection.query('SELECT 1 + 1 AS solution', function (error, results, fields) {
  if (error) throw error;
  console.log('The solution is: ', results[0].solution);
});

//connection.end();

/*var mongoose = require('mongoose');
mongoose.Promise = global.Promise;
mongoose.connect('mongodb://localhost:27017/smilethursday');
require('./models/user');*/

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
app.get('/', function(req, res) {
  res.sendFile('index.html');
});
app.get('/image.jpg', function(req, res) {
  res.sendfile(path.resolve('./uploads/image.jpg'));
});

app.post('/upload', function(req, res) {
  if (!req.files)
    return res.status(400).send('No files were uploaded.');
 
  // The name of the input field (i.e. "sampleFile") is used to retrieve the uploaded file 
  let sampleFile = req.files.file;
 
  // Use the mv() method to place the file somewhere on your server 
  mkdirp('./uploads', function (err) {
    if (err) { return res.send(err); }
  });

  sampleFile.mv('./uploads/image.jpg', function(err) {
    if (err)
      return res.status(500).send(err);
 
    res.send('File uploaded!');
  });
});

const port = 3000;
app.listen(port, function() {
  console.log('Server started on port ' + port);
});