(function() {
  var app;

  app = angular.module("giddhApp", ["satellizer", "LocalStorageModule"]);

  app.config([
    "$authProvider", function($authProvider) {
      return $authProvider.google({
        clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
      });
    }
  ]);

  app.config(function(localStorageServiceProvider) {
    return localStorageServiceProvider.setPrefix('giddh');
  });

  app.run(function($rootScope, $http, $location) {
    return console.log("app init");
  });

}).call(this);
