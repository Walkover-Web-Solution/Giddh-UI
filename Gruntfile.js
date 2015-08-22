'use strict';


module.exports = function (grunt) {
  'use strict';


  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');



  grunt.initConfig({
    coffee: {
      dist: {
        files: [
          {
            expand: true,
            cwd: "website_coffee",
            src: ['**/*.coffee'],
            dest: 'views/js',
            ext: '.js'
          }
        ]
      }
    },
    watch: {
      options: {
        livereload: 35729
      },
      src: {
        files: [
          'website_coffee/**/*.coffee'
        ],
        tasks: ['coffee']
      }
    }
  });

  grunt.event.on('watch', function(action, filepath, target) {
    grunt.log.writeln(target + ': ' + filepath + ' has ' + action);
  });

  //grunt.registerTask 'compile', ['coffee']
  grunt.registerTask('default', ['coffee', 'watch'])
};
