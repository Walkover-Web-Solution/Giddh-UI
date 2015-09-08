(function() {

  "use strict";

  var App = angular.module("giddhWebApp", [
    "App.controllers",
    "App.services",
    "App.directives",
    "App.filters",
    "ngRoute",
    "ngResource",
    'satellizer'
  ]);

  App.config(function ($routeProvider) {
    $routeProvider
      .when('/home', {
           templateUrl: '/public/website/index.html'
           //controller  : 'homeController'
      })
      .when('/pricing', {
           templateUrl: '/public/website/pricing.html'
      })
      .when('/contact', {
           templateUrl: '/public/website/contact.html'
      })
      .when('/version', {
           templateUrl: '/public/website/version.html'
      })
      .when('/login', {
           templateUrl: '/public/website/login.html'
      })
      .when('/auth/google',{
          templateUrl: '',
          controller: function ($location,$rootScope) {
          console.log($location, $rootScope, "in apps") 
         }
      })
      .otherwise({redirectTo : '/home'});
  });

  App.config(function($authProvider) {

    $authProvider.google({
      clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
    });
    console.log("yeah", $authProvider)

  });

  App.run(function($rootScope, $http) {
    $http.get('/public/javascripts/website_data.json').then(function(res){
      $rootScope.pagesData = res.data;
      console.log($rootScope.pagesData, "init pagesData");
    });
  });


}());

      
   