(function() {
  "use strict";
  var homeController;

  homeController = function($scope, $rootScope, $timeout) {
    return $scope.title = "Sarfaraz";
  };

  angular.module('giddhWebApp').controller('homeController', homeController);

}).call(this);
