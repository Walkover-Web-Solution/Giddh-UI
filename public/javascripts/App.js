(function() {
  var app;

  app = angular.module("giddhWebApp", ["satellizer", "LocalStorageModule", "ngRoute"]);

  app.config(function($routeProvider) {
    $routeProvider.when('/home', {
      templateUrl: '/public/view/home.html'
    }).otherwise({
      redirectTo: '/home'
    });
  });

  app.run(function($rootScope, $http) {
    return console.log("app init");
  });

}).call(this);
