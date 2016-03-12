var gulp = require('gulp');
var jshint = require('gulp-jshint');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var elm = require('gulp-elm');
var concat = require('gulp-concat-util');
var audiosprite = require('gulp-audiosprite');
var sass = require('gulp-sass');
var ghPages = require('gulp-gh-pages');

gulp.task('elm-init', elm.init);

gulp.task('elm-make', ['elm-init'], function(){
  return gulp.src('src/main.elm')
    .pipe(elm.make({filetype: 'js'}))
    .pipe(gulp.dest('build'));
});

gulp.task('lint', function() {
  return gulp.src('src/*.js')
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

gulp.task('sass', function() {
  return gulp.src('src/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('build/dist/css'));
});

gulp.task('sounds:prepare-sprite', function() {
  return gulp.src('sounds/*.wav')
    .pipe(audiosprite({
      log: 'notice',
      export: 'mp3,ac3',
      format: 'howler',
      gap: 0.5,
      bitrate: 320,
      path: 'sounds/'
    }))
    .pipe(gulp.dest('build/sounds'));
});

gulp.task('sounds:prepare-js', ['sounds:prepare-sprite'], function() {
  return gulp.src('build/sounds/sprite.json')
    .pipe(concat('soundSprite.js'))
    .pipe(concat.header('var soundSprite = '))
    .pipe(concat.footer(';'))
    .pipe(gulp.dest('build'));
});

gulp.task('sounds:copy-sounds', ['sounds:prepare-sprite'], function() {
  return gulp.src('build/sounds/*.{mp3,ac3}')
    .pipe(gulp.dest('build/dist/sounds'));
});

gulp.task('sounds', ['sounds:prepare-js', 'sounds:copy-sounds']);

gulp.task('prepare-js', ['lint', 'elm-make', 'sounds:prepare-js'], function() {
  return gulp.src(['build/*.js', 'src/*.js'])
    .pipe(concat('circles.js'))
    .pipe(rename('circles.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest('build/dist/js'));
});

gulp.task('prepare-html', function() {
  return gulp.src(['src/*.html'])
    .pipe(gulp.dest('build/dist'));
});

gulp.task('build', ['prepare-js', 'prepare-html', 'sass', 'sounds']);

gulp.task('watch', ['build'], function() {
  gulp.watch('src/*.elm', ['build']);
  gulp.watch('src/*.js', ['build']);
  gulp.watch('src/*.scss', ['build']);
  gulp.watch('sounds/*.wav', ['build']);
});

gulp.task('deploy', function() {
  gulp.src('build/dist/**/*')
    .pipe(ghPages());
});

gulp.task('default', ['build']);
