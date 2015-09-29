module.exports = (config) ->
  config.set
    basePath: "."
    browsers: ["PhantomJS"]
    frameworks: ["jasmine"]
    files: ["bower_components/modernizr/modernizr.js",
            "bower_components/jquery/jquery.js",
            "bower_components/angular/angular.js",
            "bower_components/angular-resource/angular-resource.js",
            "bower_components/bootstrap/dist/js/bootstrap.min.js",
            "bower_components/angular-route/angular-route.js",
            "bower_components/angular-sanitize/angular-sanitize.js",
            "bower_components/angular-local-storage/dist/angular-local-storage.js",
            "bower_components/angular-ui-tree/dist/angular-ui-tree.min.js",
            "bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js",
            "bower_components/angular-toastr/dist/angular-toastr.tpls.min.js"
            "bower_components/bootstrap/dist/js/bootstrap.js",
            "bower_components/satellizer/satellizer.js",
            "bower_components/angular-mocks/angular-mocks.js",
            "app/website/**/*.coffee",
            "app/webapp/**/*.coffee",
            "test/**/*.coffee"]
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
