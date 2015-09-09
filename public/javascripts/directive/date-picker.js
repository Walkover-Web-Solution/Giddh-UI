(function() {
  'use strict';
  angular.module('giddhApp').directive('datePicker', [
    '$filter', function($filter) {
      ({
        scope: {
          ngModel: '='
        }
      });
      return function(scope, element) {
        var setDateTime, today;
        today = new Date();
        element.datetimepicker({
          defaultSelect: false,
          yearStart: today.getFullYear(),
          minDate: $filter('date')(today, "MMM dd, yyyy"),
          minTime: $filter('date')(today, "HH:mm"),
          onChangeDateTime: function(currentTime, $input) {
            return setDateTime($input, currentTime, scope);
          }
        });
        return setDateTime = function(ele, val, scope) {
          return scope.$apply(function() {
            return scope.selectedExpiryDate = $filter('date')(val, "MMM dd, yyyy HH:mm");
          });
        };
      };
    }
  ]);

}).call(this);
