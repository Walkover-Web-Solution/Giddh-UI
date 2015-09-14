(function() {
  'use strict';
  var loginController;

  loginController = function($scope, $rootScope, $http, loginService) {
    $scope.login = {
      'banner': {
        'mainHead': 'Uh, oh!',
        'mainHead1': 'You can\'t go through because the app is invitation only.'
      }
    };
    $scope.form = {};
    $scope.getRandomInt = function(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    };
    $scope.rn1 = $scope.getRandomInt(1, 19);
    $scope.rn2 = $scope.getRandomInt(1, 19);
    $scope.isHuman = function() {
      return parseInt($scope.user.totalSum) === $scope.rn1 + $scope.rn2;
    };
    $scope.hasWhiteSpace = function(s) {
      return /\s/g.test(s);
    };
    $scope.onLoginSuccess = function(response) {
      if (angular.isUndefined(response.message)) {
        return $scope.responseMsg = "Thanks! will get in touch with you soon";
      } else {
        return $scope.responseMsg = response.message;
      }
    };
    $scope.onLoginFailure = function(response) {
      return console.log("call failed", response);
    };
    $scope.submitUserForm = function() {
      $scope.responseMsg = "loading... Submitting Form";
      if ($scope.form.$valid) {
        if ($scope.isHuman()) {
          $scope.splitFirstAndLastName($scope.user.name);
          return loginService.submitUserForm($scope.user, $scope.onLoginSuccess, $scope.onLoginFailure);
        } else {
          return $scope.responseMsg = "You are not a human being!";
        }
      }
    };
    return $scope.splitFirstAndLastName = function(name) {
      var unameArr;
      if ($scope.hasWhiteSpace(name)) {
        unameArr = name.split(" ");
        $scope.user.uFname = unameArr[0];
        return $scope.user.uLname = unameArr[1];
      } else {
        $scope.user.uFname = name;
        return $scope.user.uLname = "   ";
      }
    };
  };

  angular.module('giddhApp').controller('loginController', loginController);

}).call(this);
