'use strict';

module.exports = function (grunt) {
  'use strict';
  var testDir, srcDir, destDir, routeSrcDir, routeDestDir;

  var _ = require('underscore');
  var git_revision = require('underscore');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
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
  grunt.loadNpmTasks('grunt-execute');
  grunt.loadNpmTasks('grunt-processhtml');

// https://test-fs8eefokm8yjj.stackpathdns.com test dev

  srcDir = 'app/';
  destDir = 'public/';
  routeSrcDir = 'routes/';
  routeDestDir = 'public/routes';
  testDir = 'test/';

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
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
      libs: {
        files: [{
          expand: true,
          dot: true,
          cwd: 'bower_components/angular-sanitize/',
          src: ['angular-sanitize.js'],
          dest: destDir+'/webapp/'
        }]
      },
      all: {
        files: [{
          expand: true,
          dot: true,
          cwd: srcDir,
          src: ['**/**/images/*', '**/**/images/new/*', '**/**/css/*', '**/**/fonts/*', '**/views/*', '**/ng2/*',
              '**/ng2/**/*', '**/*.coffee','**/**/*.*', '!webapp/views/index.html', '!website/views/index.html'],
          dest: destDir
        }]
      },
      index: {
        src: srcDir + 'webapp/views/index.html',
        dest: destDir + 'webapp/views/index.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      indexWebsite: {
        src: srcDir + 'website/views/index.html',
        dest: destDir + 'website/views/index.html',
        options: {
          process: function (content, path) {
            console.log(process.env.CDN_URL)
            console.log(process.env.API_URL)
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      loginWebsite: {
        src: srcDir + 'website/views/login.html',
        dest: destDir + 'website/views/login.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      pricingWebsite: {
        src: srcDir + 'website/views/pricing.html',
        dest: destDir + 'website/views/pricing.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      magicWebsite: {
        src: srcDir + 'website/views/magic.html',
        dest: destDir + 'website/views/magic.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      aboutWebsite: {
        src: srcDir + 'website/views/about.html',
        dest: destDir + 'website/views/about.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      },
      paymentWebsite: {
        src: srcDir + 'website/views/payment.html',
        dest: destDir + 'website/views/payment.html',
        options: {
          process: function (content, path) {
            var replaced = content.replace(/<<PREFIX_THIS>>/g,process.env.PREFIX_THIS);
            // content is your whole HTML body of index page
            // use this => `content.replace("<<PREFIX_THIS>>",process.env.PREFIX_THIS)`
            // after replacing return the tweaked content
            return replaced;
          }
        }
      }
    },
    watch: {
      options: {
        livereload: 35729
      },
      src: {
        files: [
          srcDir + '/**/*.coffee', srcDir + '/**/*.html', srcDir + '**/**/*.css', routeSrcDir + "/**/*.coffee", srcDir + '/**/*.js', srcDir + '/**/**/*.js', srcDir + '/webapp/ng2/**/*.js',  srcDir + '/**/*.coffee'
        ],
        tasks: ['env:dev','coffee', 'copy', 'clean', 'cssmin', 'concat',  'preprocess:dev']
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
    cssmin: {
      minifyCss: {
        files: [{
          expand: true,
          cwd: 'public/webapp/Globals/css',
          src: ['*.css', '!*.min.css'],
          dest: 'public/webapp/Globals/css',
          ext: '.css'
        }]
      }
    },
    concat: {
      options: {
        stripBanners: true,
        separator: ';', 
        banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - ' +
          '<%= grunt.template.today("yyyy-mm-dd") %> */' + '\n\n',
      },
      js:{
        files:{
          'public/webapp/app.js': ['public/webapp/root.js', 'public/webapp/Root/*.js', 'public/webapp/Root/**/*.js','public/webapp/**/*.js','!public/webapp/**/core_bower.min.js','!public/webapp/**/newRelic.js','!public/webapp/ng2/*.js', '!public/webapp/ng2/**/*.js'],
          'public/webapp/ng2.js': ['public/webapp/ng2/**/*.services.js','public/webapp/ng2/**/*.component.js','public/webapp/ng2/*.js'],
          'public/webapp/newRelic.js': ['app/webapp/Globals/modified_lib/newRelic.js'],
          'public/webapp/_extras.js': ['app/webapp/Globals/modified_lib/angular-charts.js', 'app/webapp/Globals/modified_lib/jspdf.debug.js'],
          'public/webapp/Globals/css/giddh.min.css': ['public/webapp/Globals/css/all_bower.css', 'public/webapp/Globals/css/modiefied-bootstrap.css', 'public/webapp/Globals/css/new-style.css']
        }
      }
    },
    clean: {
      js: [
        "public/webapp/app.js",
        "public/webapp/ng2.js",
        "public/webapp/newRelic.js",
        "public/webapp/_extras.js",
        "public/webapp/css/giddh.min.css"
      ]
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
        NODE_ENV: 'DEVELOPMENT',
        PREFIX_THIS: process.env.CDN_URL
      },
      prod: {
        NODE_ENV: 'PRODUCTION',
        PREFIX_THIS: process.env.CDN_URL
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
        cssDest: 'public/webapp/Globals/css/all_bower.css',
        bowerOptions: {
          relative: false
        },
        exclude: [
          'v-accordion',
          'bootstrap',
          'fullpage.js',
          'angular-vidbg',
          'angular-recaptcha',
          'angular-fullpage.js',
          'angular-bootstrap'
        ],
        mainFiles: {
          'perfect-scrollbar': 'css/perfect-scrollbar.min.css',
          'angular-toastr': 'dist/angular-toastr.min.css',
          'angular-gridster': 'dist/angular-gridster.min.css',
          'ui-select': 'dist/select.min.css',
          'font-awesome': 'css/font-awesome.min.css'
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
          'jquery-ui',
          'angular',
          'angular2',
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
          'Chart.js',
          'angular-ui-switch',
          'ng-csv',
          'angular-vidbg',
          'fullpage.js',
          'angular-fullpage.js',
          'angular-wizard',
          'angular-google-chart',
          'angular-file-saver',
          'intl-tel-input',
          'international-phone-number',
          'angular-file-saver',
          'angular-gridster',
          'ment.io',
          'trix',
          'angular-trix',
          'tinymce',
          'tinymce-mention',
          'angular-ui-tinymce'
        ],
        dependencies: {
          'jquery': 'modernizr',
          'angular': 'jquery',
          'bootstrap': 'angular',
          'angular-bootstrap': 'bootstrap',
          'underscore': 'angular-bootstrap',
          'intl-tel-input': 'jquery',
          'international-phone-number':'intl-tel-input'
        },
        mainFiles: {
          'underscore': 'underscore-min.js',
          'angular-bootstrap': 'ui-bootstrap-tpls.min.js',
          'perfect-scrollbar': 'js/min/perfect-scrollbar.jquery.min.js',
          'moment': 'min/moment-with-locales.min.js',
          'angular-toastr': 'dist/angular-toastr.tpls.min.js'
        },
        callback: function(mainFiles, component) {
          console.log(mainFiles)
          return _.map(mainFiles, function(filepath) {
            var min = filepath.replace(/\.js$/, '.min.js');
            return grunt.file.exists(min) ? min : filepath;
          });
        },
        process: function(src) {
          return "\n" + src + "\n\n";
        }
      }
    },
    execute: {
      target: {
        src: ['git_revision.js']
      }
    },
    processhtml:{
      dist: {
        options: {
          process: true,
        },
        files: [
          {
            expand: true,
            cwd: srcDir,
            src: ['*.html'],
            dest: destDir,
            ext: '.html'
          }
        ]
      }
    }
  });

  grunt.event.on('watch', function (action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

  grunt.registerTask('customCopy', ['env:dev', 'copy']);

  grunt.registerTask('tempRun', ['copy:indexWebsite'])

  grunt.registerTask('default', ['coffeelint', 'customCopy', 'coffee', 'watch', 'bower_concat', 'cssmin', 'concat'])

  grunt.registerTask('init', ['env:dev', 'copy', 'coffee', 'clean','bower_concat', 'cssmin', 'concat', 'preprocess:dev'])

  grunt.registerTask('init-prod', ['env:prod', 'copy', 'coffee', 'clean', 'bower_concat',  'cssmin', 'concat', 'uglify', 'preprocess:prod'])

  grunt.registerTask('test', [
    'coffee',
    //'karma:unit'
  ]);

  grunt.registerTask('addCommitInfo', ['execute']);

};
