(function() {
  var app;

  app = angular.module("giddhApp", ["satellizer", "LocalStorageModule"]);

  app.config([
    "$authProvider", function($authProvider) {
      return $authProvider.google({
        clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
      });
    }
  ]);

  app.config(function(localStorageServiceProvider) {
    return localStorageServiceProvider.setPrefix('giddh');
  });

  app.run(function($rootScope, $http, $location) {
    return console.log("app init");
  });

  (function() {
    angular.module('giddhApp', []).directive('autoActive', [
      '$location', function($location) {
        return {
          restrict: 'A',
          scope: false,
          link: function(scope, element) {
            var setActive;
            setActive = function() {
              var cElem, fURL, path, pathT;
              fURL = $location.absUrl().split('/');
              pathT = fURL.reverse();
              path = pathT[0];
              console.log;
              if (path) {
                cElem = element.find('li a.' + path);
                return cElem.addClass('active');
              } else {
                cElem = element.find('.nav li a.home');
                return cElem.addClass('active');
              }
            };
            setActive();
            scope.$on('$locationChangeSuccess', setActive);
          }
        };
      }
    ]);
  })();

}).call(this);
