var express = require('express');
var router = express.Router();
var path = require('path');
var mysql = require('mysql');
var mkdirp = require('mkdirp');
var conn = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'asdf',
  database : 'smilethursday'
});
var spawn = require('child_process').spawn;

router.post('/users/login', function(req, res) {
  var fbId = req.body.fbId;
  conn.query("INSERT INTO Users (fbId) VALUES ('" + fbId + "') ON DUPLICATE KEY UPDATE fbId='" + fbId + "'", function(err, results) {
    if (err) { throw err; }
    res.json(results);
  });
});

router.post('/users', function(req, res) {
  var fbId = req.body.fbId;
  var numSmiles = req.body.numSmiles;
  conn.query("UPDATE Users SET smilePoints=smilePoints + " + numSmiles + " WHERE fbId='" + fbId + "'", function(err, results) {
    if (err) { throw err; }
    res.json(results);
  });
});

router.get('/posts', function(req, res) {
  var scope = req.query.scope;
  if (scope == 'global') {
    conn.query("SELECT * FROM Posts WHERE privacy='public' ORDER BY date DESC", function(err, results) {
      if (err) { throw err; }
      console.log(results);
      res.json(results);
    });
  }
});

router.post('/posts/friends', function(req, res) {
  var friendIds = req.query.ids;
  var friendsQuery = "'" + friendIds[0] + "'";
  for (var i = 1; i < friendIds.length; i++) {
    friendsQuery += " OR '" + friendIds[i] + "'";
  }
  var query = "SELECT * FROM Posts WHERE fbId IN (" + friendsQuery + ") AND (privacy='friends' OR privacy='public') ORDER BY date";
  conn.query(query, function(err, results) {
    if (err) { throw err; }
    res.json(results);
  });
});

router.get('/posts/:uid', function(req, res) {
  var uid = req.params.uid;
  conn.query("SELECT * FROM Posts WHERE uid='" + uid + "' ORDER BY date", function(err, results) {
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
    num_faces: req.body.num_faces,
    date: Date.now(),
    privacy: req.body.privacy
  };
  conn.query("INSERT INTO Posts (uuid, uid, date, num_faces, privacy) VALUES ('" + post.uuid + "','" 
      + post.uid + "', " + post.date + ", '" + post.num_faces + "', '" + post.privacy + "');", function(err, results) {
    if (err) { throw err; }
    var image_id = results.insertId;
    var imageFile = req.files.file;
    mkdirp('./smiles');
    imageFile.mv('./smiles/' + image_id + '.jpg');

    // Verify face results
    var process = spawn('python',["./verifyFace.py", image_id]);
    process.stdout.on('data', function (data) {
      var numSmiles = parseInt(data.toString('utf8')[0]);
      conn.query("UPDATE Users SET smilePoints=smilePoints + " + numSmiles + " WHERE fbId='" + fbId + "'", function(err, results) {
      if (err) { throw err; }
        res.json({data: numSmiles});
      });
    });
  });
});

module.exports = router;