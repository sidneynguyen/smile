var express = require('express');
var router = express.Router();
var passport = require('passport');
var mongoose = require('mongoose');
var FacebookTokenStrategy = require('passport-facebook-token');
var mysql = require('mysql');
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : '',
  database : 'smilethursday'
});

router.post('/facebook/token',
  passport.authenticate('facebook-token'),
  function (req, res) {
    res.json(req.user);
  }
);

passport.use(new FacebookTokenStrategy({
  clientID: 'insert id',
  clientSecret: 'insert secret'
}, function(accessToken, refreshToken, profile, done) {
  User.find({fbId: profile.id}, function(err, user) {
    if (err) {
      return done(err);
    }
    else if (user) {
      user.token = accessToken;
      user.save(function(err, user) {
        if (err) {
          return done(err);
        }
        return done(err, user);
      });
    } else {
      var user = new User({
        token: accessToken,
        fbId: profile.id
      });
      user.save(function(err, user) {
        if (err) {
          return done(err);
        }
        return done(err, user);
      });
    }
  });
}));

passport.serializeUser(function(user, done) {
  done(null, user._id);
});

passport.deserializeUser(function(id, done) {
  db.selectUserById(id, function(err, user) {
    done(err, user);
  });
});

module.exports = router;