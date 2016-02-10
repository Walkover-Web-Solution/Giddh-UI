'use strict';

module.exports = function (grunt) {
  'use strict';
  var testDir, srcDir, destDir, routeSrcDir, routeDestDir;

  var _ = require('underscore');
  grunt.loadNpmTasks('grunt-bower-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-preprocess');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-env');

  srcDir = 'app/';
  destDir = 'public/';
  routeSrcDir = 'routes/';
  routeDestDir = 'public/routes';
  testDir = 'test/';

  grunt.initConfig({
    coffeelint: {
      app: ['karma.conf.coffee', "" + srcDir + "/**/*.coffee", "" + testDir + "/**/*.coffee", routeSrcDir + "/**/*.coffee"],
      options: {
        max_line_length: {
          level: 'ignore'
        }
      }
    },
    coffee: {
      dist: {
        files: [
          {
            expand: true,
            cwd: srcDir,
            src: ['**/*.coffee'],
            dest: destDir,
            ext: '.js'
          },
          {
            expand: true,
            cwd: routeSrcDir,
            src: ['**/*.coffee'],
            dest: routeDestDir,
            ext: '.js'
          }
        ]
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: srcDir,
          src: ['**/images/*', '**/css/*', '**/fonts/*', '**/views/*', "**/js/newRelic.js", "**/js/jspdf.debug.js",  "**/js/angular-charts.js"],
          dest: destDir
        }]
      }
    },
    watch: {
      options: {
        livereload: 35729
      },
      src: {
        files: [
          srcDir + '/**/*.coffee', srcDir + '/**/*.html', srcDir + '/**/*.css', routeSrcDir + "/**/*.coffee"
        ],
        tasks: ['coffee', 'copy', 'clean', 'concat', 'env:dev', 'preprocess:dev']
      }
    },
    karma: {
      options: {
        configFile: 'karma.conf.coffee'
      },
      unit: {
        singleRun: true
      },
      continuous: {
        autoWatch: true,
        reporters: 'dots'
      }
    },
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      js:{
        files:{
          'public/webapp/app.js': ['public/webapp/js/**/*.js', '!public/**/newRelic.js', '!public/**/angular-charts.js', '!public/**/angular-charts.js']
        }
      },
      extras: {
        src: ['public/webapp/js/angular-charts.js', 'public/webapp/js/jspdf.debug.js'],
        dest: 'public/webapp/_extras.js',
      }
    },
    clean: {
      js: ["public/webapp/app.js"]
    },
    uglify: {
      options: {
        mangle: false
      },
      dist: {
        files: {
          'public/webapp/app.min.js': ['public/webapp/app.js']
        }
      }
    },
    env: {
      dev: {
        NODE_ENV: 'DEVELOPMENT'
      },
      prod: {
        NODE_ENV: 'PRODUCTION'
      }
    },
    preprocess:{
      dev:{
        files:{
          'public/webapp/views/index.html': ['public/webapp/views/index.html']
        }
      },
      prod:{
        files:{
          'public/webapp/views/index.html': ['public/webapp/views/index.html']
        }
      }
    },
    bower_concat: {
      onlyCss: {
        cssDest: 'public/webapp/css/all_bower.min.css',
        bowerOptions: {
          relative: false
        },
        exclude: [
          'v-accordion'
        ],
        mainFiles: {
          'bootstrap': 'dist/css/bootstrap.min.css',
          'perfect-scrollbar': 'css/perfect-scrollbar.min.css',
          'angular-toastr': 'dist/angular-toastr.min.css',
          'ui-select': 'dist/select.min.css'
        },
        callback: function(mainFiles, component) {
          return _.map(mainFiles, function(filepath) {
            // Use minified css files if available 
            var min = filepath.replace(/\.css$/, '.min.css');
            return grunt.file.exists(min) ? min : filepath;
          });
        }
      },
      coreJs: {
        dest: 'public/webapp/core_bower.min.js',
        bowerOptions: {
          relative: false
        },
        include: [
          'modernizr',
          'jquery',
          'angular',
          'bootstrap',
          'angular-bootstrap',
          'underscore',
          'angular-sanitize',
          'satellizer',
          'angular-animate',
          'angular-resource',
          'angular-ui-router',
          'angular-translate',
          'angular-filter',
          'angular-mocks',
          'angular-local-storage',
          'perfect-scrollbar',
          'moment',
          'angular-toastr',
          'angular-ui-tree',
          'ng-file-upload',
          'angular-filter',
          'ui-select',
          'html2canvas',
          'Chart.js'
        ],
        dependencies: {
          'jquery': 'modernizr',
          'angular': 'jquery',
          'bootstrap': 'angular',
          'angular-bootstrap': 'bootstrap',
          'underscore': 'angular-bootstrap'
        },
        mainFiles: {
          'underscore': 'underscore-min.js',
          'angular-bootstrap': 'ui-bootstrap-tpls.min.js',
          'perfect-scrollbar': 'js/min/perfect-scrollbar.jquery.min.js',
          'moment': 'min/moment-with-locales.min.js',
          'angular-toastr': 'dist/angular-toastr.tpls.min.js'
        },
        callback: function(mainFiles, component) {
          return _.map(mainFiles, function(filepath) {
            var min = filepath.replace(/\.js$/, '.min.js');
            return grunt.file.exists(min) ? min : filepath;
          });
        },
        process: function(src) {
          return "\n" + src + "\n\n";
        }
      }
    }
  });

  grunt.event.on('watch', function (action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

  grunt.registerTask('default', ['coffeelint', 'copy', 'coffee', 'watch', 'bower_concat'])

  grunt.registerTask('init', ['copy', 'coffee', 'env:dev', 'clean', 'concat', 'preprocess:dev', 'bower_concat'])

  grunt.registerTask('init-prod', ['copy', 'coffee', 'clean', 'env:prod', 'concat', 'uglify', 'bower_concat', 'preprocess:prod'])

  grunt.registerTask('test', [
    'coffee',
    'karma:unit'
  ]);

  grunt.registerTask('bowerconcat', [
    'bower_concat'
  ]);
};
