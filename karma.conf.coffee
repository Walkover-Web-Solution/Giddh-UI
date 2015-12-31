module.exports = (config) ->
  config.set
    basePath: "."
    browsers: ["PhantomJS"]
    frameworks: ["jasmine"]
    files: [
      "bower_components/modernizr/modernizr.js",
      "bower_components/jquery/jquery.min.js",
      "bower_components/angular/angular.min.js",
      "bower_components/angular-resource/angular-resource.min.js",
      "bower_components/bootstrap/dist/js/bootstrap.min.js",
      "bower_components/angular-route/angular-route.min.js",
      "bower_components/angular-sanitize/angular-sanitize.min.js",
      "bower_components/v-accordion/dist/v-accordion.js",
      "bower_components/angular-local-storage/dist/angular-local-storage.js",
      "bower_components/moment/min/moment-with-locales.min.js",
      "bower_components/angular-ui-tree/dist/angular-ui-tree.min.js"
      "bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js",
      "bower_components/angular-toastr/dist/angular-toastr.tpls.min.js",
      "bower_components/angular-filter/dist/angular-filter.min.js",
      "bower_components/angular-ui-router/release/angular-ui-router.min.js",
      "bower_components/bootstrap/dist/js/bootstrap.js",
      "bower_components/satellizer/satellizer.js",
      "bower_components/underscore/underscore-min.js",
      "bower_components/angular-mocks/angular-mocks.js",
      "bower_components/angular-animate/angular-animate.min.js",
      "bower_components/angular-translate/angular-translate.min.js",
      "bower_components/perfect-scrollbar/js/min/perfect-scrollbar.jquery.min.js",
      "bower_components/ng-file-upload/ng-file-upload.min.js",
      "app/website/**/*.coffee",
      "app/webapp/**/*.coffee",
      "test/**/*.coffee"
    ]
    plugins: [
      'karma-jasmine',
      'karma-script-launcher',
      'karma-phantomjs-launcher',
      'karma-junit-reporter',
      'karma-coverage',
      'karma-coffee-preprocessor'
    ]
    preprocessors: {
      "app/website/**/*.coffee": ["coffee", "coverage"]
      "app/webapp/**/*.coffee": ["coffee", "coverage"]
      "test/**/*.coffee": ["coffee"]
    }
    reporters: [
      'dots', 'junit', 'coverage'
    ]
    junitReporter: {
      outputFile: 'target/test-results.xml'
    }
    coverageReporter:
      type: "text"
      dir: "target/coverage/"
    htmlReporter:
      outputDir: 'target/karma_html'
      template: __dirname + '/jasmine_template.html'
