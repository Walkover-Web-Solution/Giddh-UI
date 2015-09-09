(function() {
  'use strict';
  angular.module('giddhApp').directive('datePicker', [
    '$filter', function($filter) {
      return {
        restrict: 'A',
        scope: false,
        link: function(scope, element) {
          var setActive;
          setActive = function() {
            var elem, fURL, path, pathT;
            elem = void 0;
            fURL = void 0;
            path = void 0;
            pathT = void 0;
            fURL = $location.absUrl().split('/');
            pathT = fURL.reverse();
            path = pathT[0];
            if (path) {
              elem = angular.element('.nav li a.' + path);
              return elem.addClass('active');
            } else {
              elem = angular.element('.nav li a.home');
              return elem.addClass('active');
            }
          };
          setActive();
          scope.$on('$locationChangeSuccess', setActive);
        }
      };
    }
  ]);

}).call(this);
