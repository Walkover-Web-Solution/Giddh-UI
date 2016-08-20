
angular.module('networthDirectives', [])
.directive 'netWorth',[() -> {
  restrict: 'E'
  templateUrl: '/public/webapp/Dashboard/Networth/net-worth.html'
  controller: 'networthController'
  link: (scope,elem,attr) ->

}]