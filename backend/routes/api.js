var express = require('express');
var router = express.Router();
var path = require('path');
var mysql = require('mysql');
var mkdirp = require('mkdirp');
var conn = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : '',
  database : 'smilethursday'
});

router.get('/posts', function(req, res) {
  var scope = req.query.scope;
  if (scope == 'global') {
    conn.query('SELECT * FROM Posts ORDER BY date', function(err, results) {
      if (err) { throw err; }
      console.log(results);
      res.json(results);
    });
  }
});

router.post('/posts', function(req, res) {
  var friendIds = req.query.ids;
  var friendsQuery = "'" + friendIds[0] + "'";
  for (var i = 1; i < friendIds.length; i++) {
    friendsQuery += " OR '" + friendIds[i] + "'";
  }
  var query = "SELECT * FROM Posts WHERE fbId IN (" + friendsQuery + ") ORDER BY date";
  conn.query(query, function(err, results) {
    if (err) { throw err; }
    res.json(results);
  });
});

router.get('/posts/:uid', function(req, res) {
  var uid = req.params.uid;
  conn.query("SELECT * FROM Posts WHERE fbId='" + uid + "' ORDER BY date", function(err, results) {
    if (err) { throw err; }
    res.json(results);
  });
});

router.get('/image', function(req, res) {
  var image_id = req.query.image_id;
  res.sendFile(path.resolve('./smiles/' + image_id + '.jpg'));
});

router.post('/posts', function(req, res) {
  var post = {
    uuid: req.body.uuid,
    uid: req.body.uid,
    num_faces: req.body.num_faces
  };
  conn.query("INSERT INTO Posts (uuid, uid, date, num_faces) VALUES ('" + post.uuid + "','" 
      + post.uid + "', NOW(), '" + post.num_faces + "');", function(err, results) {
    if (err) { throw err; }
    var image_id = results.insertId;
    var imageFile = req.files.file;
    mkdirp('./smiles');
    //mkdirp('./smiles/' + post.uid);
    imageFile.mv('./smiles/' + image_id + '.jpg');
    res.json(results);
  });
});

module.exports = router;