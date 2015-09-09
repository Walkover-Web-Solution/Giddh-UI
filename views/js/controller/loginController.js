(function() {
  'use strict';
  var loginController;

  loginController = function($scope, $rootScope, $http, $timeout, $location) {
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
    return $scope.submitUserForm = function() {
      var details, unameArr;
      if ($scope.form.$valid) {
        details = [];
        if ($scope.hasWhiteSpace($scope.user.name)) {
          console.log("dude you rock");
          unameArr = $scope.user.name.split(" ");
          details.uFname = unameArr[0];
          details.uLname = unameArr[1];
        } else {
          details.uFname = $scope.user.name;
          details.uLname = "   ";
        }
        return $http.post('/submitBetaInviteDetails', {
          uFname: details.uFname,
          uLname: details.uLname,
          email: $scope.user.email,
          company: $scope.user.company,
          reason: $scope.user.reason
        }).then((function(response) {
          console.log('then', response);
          if (response.status === 200) {
            $scope.blank = {};
            $scope.user = angular.copy($scope.blank);
            $scope.form.$setPristine();
            if (angular.isUndefined(response.data.message)) {
              return $scope.responseMsg = "Thanks! will get in touch with you soon";
            } else {
              return $scope.responseMsg = response.data.message;
            }
          }
        }), function(response) {
          return console.log('in response', response);
        });
      }
    };
  };

  angular.module('giddhApp').controller('loginController', loginController);

}).call(this);
