adminPanel = angular.module('adminPanel', [
	"satellizer",
    "LocalStorageModule",
    "ui.bootstrap",
    "toastr",
    "ui.router"
])

.config(function($stateProvider, $urlRouterProvider, $locationProvider) {
	
	$urlRouterProvider.otherwise('/login');
	
	$stateProvider.state('login', {
      url: '/login',
      templateUrl: '/public/adminPanel/views/login.html',
      controller: 'adminLoginController',
      controllerAs: 'login'
    })

    .state('admin-panel', {
      url: '/admin-panel',
      templateUrl: '/public/adminPanel/views/panel.html',
      controller: 'adminPanelController',
      controllerAs: 'admin'
    })
})

.config([
    '$authProvider', function($authProvider) {
      $authProvider.google({
        clientId: '641015054140-3cl9c3kh18vctdjlrt9c8v0vs85dorv2.apps.googleusercontent.com'
      });
      $authProvider.twitter({
        clientId: 'w64afk3ZflEsdFxd6jyB9wt5j'
      });
      $authProvider.linkedin({
        clientId: '75urm0g3386r26'
      });
      return $authProvider.linkedin({
        url: '/auth/linkedin',
        authorizationEndpoint: 'https://www.linkedin.com/uas/oauth2/authorization',
        redirectUri: window.location.origin + "/login/",
        requiredUrlParams: ['state'],
        scope: ['r_emailaddress'],
        scopeDelimiter: ' ',
        state: 'STATE',
        type: '2.0',
        popupOptions: {
          width: 527,
          height: 582
        }
      });
    }
])
