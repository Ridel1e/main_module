#function makeid()
#{
#var text = "";
#var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
#
#for( var i=0; i < 5; i++ )
#text += possible.charAt(Math.floor(Math.random() * possible.length));
#
#return text;
#}

makeKey = () ->
  possibleCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  key = "";

  for i in [1..5]
    key += possibleCharacters.charAt(
      Math.floor(Math.random() * possibleCharacters.length));

  return key

module.exports.makeKey = makeKey