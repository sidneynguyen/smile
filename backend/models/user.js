var mongoose = require('mongoose');

var userSchema = mongoose.Schema({
  token: String,
  fbId: String,
});

mongoose.model('User', userSchema);