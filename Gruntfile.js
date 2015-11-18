'use strict';

module.exports = function (grunt) {
  'use strict';
  var testDir, srcDir, destDir, routeSrcDir, routeDestDir;

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
          src: ['**/images/*', '**/css/*', '**/fonts/*', '**/views/*'],
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
    concat: {
      js:{
        files:{
          'public/webapp/app.js': ['public/webapp/**/*.js']
        }
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
    }
  });

  grunt.event.on('watch', function (action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

  grunt.registerTask('default', ['coffeelint', 'copy', 'coffee', 'watch'])

  grunt.registerTask('init', ['copy', 'coffee', 'env:dev', 'clean', 'concat', 'preprocess:dev'])

  grunt.registerTask('init-prod', ['copy', 'coffee', 'clean', 'env:prod', 'concat', 'uglify', 'preprocess:prod'])

  grunt.registerTask('test', [
    'coffee',
    'karma:unit'
  ]);
};
