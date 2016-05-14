var soundPlayer = new Howl(soundSprite);

var elm = Elm.Main.fullscreen();

elm.ports.playSound.subscribe(function(sound) {
  soundPlayer.play(sound);
});
