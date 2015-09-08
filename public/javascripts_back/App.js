(function() {

  "use strict";

  var App = angular.module("giddhWebApp", ["ngRoute"]);

  App.config(function ($routeProvider) {
    $routeProvider
      .when('/home', {
           templateUrl: '/public/view/home.html'
           //controller  : 'homeController'
      })
      .when('/pricing', {
           templateUrl: '/public/view/pricing.html'
      })
      .when('/contact', {
           templateUrl: '/public/view/contact.html'
      })
      .when('/version', {
           templateUrl: '/public/view/version.html'
      })
      .when('/login', {
           templateUrl: '/public/view/login.html'
      })
      .when('/auth/google',{
          templateUrl: '',
          controller: function ($location,$rootScope) {
          console.log($location, $rootScope, "in apps") 
         }
      })
      .otherwise({redirectTo : '/home'});
  });



}());

      
   