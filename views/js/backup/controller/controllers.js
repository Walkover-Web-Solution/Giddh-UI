//var App = angular.module("App", []);

angular.module("App").controller('homeController', ['$scope', function($scope) { 
  $scope.title = 'This Month\'s Bestsellers'; 
}]);


/*
	App.controller("pricingController", ["$scope", function ($scope, UtilSrvc){
		$scope.aVariable = 'anExampleValueWithinScope';
		$scope.valueFromService = UtilSrvc.helloWorld("User");
		console.log("dude hit me too");
	}]);

	homeController = function($scope, $rootScope, $http, $timeout, $translate){
	};

	angular.module("App").controller("homeController", homeController)
*/
/*
	App.controller("pricingController", ["$scope", "$rootScope", "$http", "$timeout", function($scope, $rootScope, $http, $timeout){
		$scope.pricing = $rootScope.pagesData.pricing;
	}]);

	app.controller("contactController", ["$scope", "$rootScope", "$http", "$timeout", function($scope, $rootScope, $http, $timeout){
		$scope.contact = $rootScope.pagesData.contact;
		$scope.form = {};
		$scope.integerval = /^\d*$/;
		// function to submit the form after all validation has occurred			
		$scope.submitForm = function() {

			// check to make sure the form is completely valid
			if ($scope.form.$valid) {
				console.log($scope.form);
				var htmlBody = '<div>Name: ' + $scope.form.uEmail.$viewValue + '</div>' +
				'<div>Email: ' + $scope.form.uNumber.$viewValue + '</div>' +
                 '<div>Email: ' + $scope.form.uEmail.$viewValue + '</div>' +
                 '<div>Message: ' + $scope.form.uMessage.$viewValue + '</div>' +
                 '<div>Date: ' + (new Date()).toString() + '</div>';

				console.log('our form is amazing', htmlBody);
				
				$http({
			      url: 'https://api.postmarkapp.com/email',
			      method: 'POST',
			      data: {
			        'From': 'foo@foo.com',
			        'To': 'bar@bar.com',
			        'HtmlBody': htmlBody,
			        'Subject': 'New Contact Form Submission'
			      },
			      headers: {
			        'Accept': 'application/json',
			        'Content-Type': 'application/json',
			        'X-Postmark-Server-Token': '8569dcd45-6a1a-4e7b-ae75-ea37629de4'
			      }
			    }).
			    success(function (data) {
			    	$scope.success = true;
			    	$scope.user = {};
			    }).
			    error(function (data) {
			    	$scope.error = true;
			    });
			}

		};
	}]);

	App.controller("versionController", ["$scope", "$rootScope", "$http", "$timeout", function($scope, $rootScope, $http, $timeout){
		$scope.version = $rootScope.pagesData.version;
	}]);

	App.controller("loginController", ["$scope", "$rootScope", "$http", "$timeout", "$auth", function($scope, $rootScope, $http, $timeout, $auth){
		$scope.login = $rootScope.pagesData.login;


		var rand = Math.random() * 4;
        window.onload = function () {
            alertMsg(parseInt(rand));
        }
        var alertMsg = function() {
			$timeout(alertMsg, 5000);
			var id = parseInt(Math.random()*3)
            switch (id) {
            	case 0:
                    $("#tipscnt").html('Tip : "Every transaction has a statement."');
                    break;
                case 1:
                    $("#tipscnt").html('Tip : "Your account book will never contain your name."');
                    break;
                case 2:
                    $("#tipscnt").html('Tip : "Every statement will have an entry."');
                    break;
                case 3:
                    $("#tipscnt").html('Tip : "Ateast two things will happen in every statement."');
                    break;
                case 3:
                    $("#tipscnt").html('Tip : "Accounting works on double entry system"');
                    break;
            }
        }
        $timeout(alertMsg, 5000);

        $scope.loginWithGoogle=function() {
	    };

	    $scope.authenticate = function(provider) {
	    	$auth.authenticate(provider).then(function(response) {
	    		$location.path('/');
	        	console.log('You have successfully created a new account');
	        })
	        .catch(function(response) {
	          console.log(response);
	        });
	    }
     


	}]);

(function() {

  "use strict";

  var App = angular.module("App", []);

  var App = angular.module("App", [
    "App.controllers",
    'satellizer',
    'pascalprecht.translate'
  ]);


  App.config(function($authProvider) {
    $authProvider.google({
      clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
    });
  });

  // App.run(function($rootScope, $http) {
  //   $http.get('/public/javascripts/website_data.json').then(function(res){
  //     $rootScope.pagesData = res.data;
  //     console.log($rootScope.pagesData, "init pagesData");
  //   });
  // });
  
  App.config(['$translateProvider', function ($translateProvider) {
      $translateProvider.translations('en', {
        'TITLE': 'Hello',
        'FOO': 'This is a paragraph'
      });
     
      $translateProvider.translations('de', {
        'TITLE': 'Hallo',
        'FOO': 'Dies ist ein Absatz'
      });
     
      $translateProvider.preferredLanguage('en');
    }]);

}());

      
   // $http.get('/public/javascripts/website_data.json').then(function(res){
		// 	$scope.home = res.data.home;
		// 	console.log(res,  "loaded")
		// });
		//console.log("load controller", $translate('TITLE'));
		
		var changeText = function() {
			$timeout(changeText, 5000);
	        var id = parseInt(Math.random()*4)
			var heading = angular.element( document.querySelector( '#imd' ));
			var subHeading = angular.element( document.querySelector( '#imdContent' ));
			switch(id){
				case 0:
				heading.html('Analyse BIG<br/> DATA');
				subHeading.html('Accounting is nothing but keeping your transactions in an efficient way. Your eyes could have limitations; let me show you everything in one shot.');
				break;
				case 1:
				heading.html("Ant or<br/> Elephant"); 
				subHeading.html('Accounting is a breadth of every Business, small business, Start-ups and even for a person. It makes you alive or at least makes you feel');
				break;
				case 2:
				heading.html('Not for<br/> Accountants');	
				subHeading.html('I am not scary like you imagine accounts. I am simple, basic and very friendly and will never let you regret.');
				break;
				case 3:
				heading.html("Accounting is necessary"); 
				subHeading.html("Our perception says accounting is the synonyms of necessities, Use any accounting software but use... that’s our motto and that’s why we are.");
				break;
				case 4:
				heading.html("Accounting is the foundation"); 
				subHeading.html('Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.');
				break;
			}
		}
		//$timeout(changeText, 5000);
	
*/