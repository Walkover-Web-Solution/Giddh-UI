(function() {
  'use strict';
  var loginController;

  loginController = function($scope, $rootScope, $http, $timeout, $auth, localStorageService) {
    var alertMsg, rand;
    $scope.authenticate = function(provider) {
      return $auth.authenticate(provider).then(function(response) {
        console.log(response, 'You have successfully created a new account');
        console.log("in status", response.data.userDetails);
        localStorageService.set("_userDetails", response.data.userDetails);
        return window.location = "/app/";
      })["catch"](function(response) {
        return console.log(response);
      });
    };
    $scope.login = {
      'banner': {
        'mainHead': 'Welcome to the world of',
        'mainHead1': 'secure and online accounting'
      }
    };
    rand = Math.random() * 4;
    window.onload = function() {
      alertMsg(parseInt(rand));
    };
    return alertMsg = function() {
      var ele, id;
      $timeout(alertMsg, 5000);
      id = parseInt(Math.random() * 3);
      ele = angular.element(document.querySelector('#tipscnt'));
      switch (id) {
        case 0:
          ele.html('Tip : "Every transaction has a statement."');
          break;
        case 1:
          ele.html('Tip : "Your account book will never contain your name."');
          break;
        case 2:
          ele.html('Tip : "Every statement will have an entry."');
          break;
        case 3:
          ele.html('Tip : "Ateast two things will happen in every statement."');
          break;
        case 3:
          ele.html('Tip : "Accounting works on double entry system"');
      }
      return;
      return $timeout(alertMsg, 5000);
    };
  };

  angular.module('giddhApp').controller('loginController', loginController);

}).call(this);
