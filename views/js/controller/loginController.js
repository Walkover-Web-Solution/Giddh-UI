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
    $scope.hasWhiteSpace = function(s) {
      return /\s/g.test(s);
    };
    $scope.onLoginSuccess = function(response) {
      $scope.user = {};
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
        $scope.splitFirstAndLastName($scope.user.name);
        return loginService.submitUserForm($scope.user, $scope.onLoginSuccess, $scope.onLoginFailure);
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
