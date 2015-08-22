(function() {
  var app;

  app = angular.module("giddhApp", ["satellizer"]);

  app.config([
    "$authProvider", function($authProvider) {
      return $authProvider.google({
        clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
      });
    }
  ]);

  app.run(function($rootScope, $http) {
    return console.log("app init");
  });

}).call(this);
