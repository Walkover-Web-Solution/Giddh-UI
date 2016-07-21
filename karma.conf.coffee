module.exports = (config) ->
  config.set
    basePath: "."
    browsers: ["PhantomJS"]
    frameworks: ["jasmine"]
    files: [
      "public/webapp/core_bower.min.js",
      "public/webapp/_extras.js",
      "app/website/**/*.coffee",
      "app/webapp/**/*.coffee",
      "app/webapp/**/**/*.coffee",
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
