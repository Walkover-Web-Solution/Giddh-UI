'use strict';

module.exports = function (grunt) {
  'use strict';
  var webDir, srcDir, destDir;

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-karma');

  srcDir = 'app/';
  destDir = 'public/';

  grunt.initConfig({
    coffee: {
      dist: {
        files: [
          {
            expand: true,
            cwd: srcDir,
            src: ['**/*.coffee'],
            dest: destDir,
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
          src: ['**/images/*', '**/css/*', '**/fonts/*', '**/template/*'],
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
          webDir + '/**/*.coffee'
        ],
        tasks: ['coffee']
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
    }
  });

  grunt.event.on('watch', function (action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

  grunt.registerTask('default', ['copy', 'coffee', 'watch'])

  grunt.registerTask('run', ['copy', 'coffee'])

  grunt.registerTask('test', [
    'coffee',
    'karma:unit'
  ]);
};
