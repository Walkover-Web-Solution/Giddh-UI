angular.module("giddhApp").controller("loginController", ["$scope", "$rootScope", "$http", "$timeout", "$auth", function($scope, $rootScope, $http, $timeout, $auth ){

	/*webpage data*/
    $scope.login = {
        "banner": {
            "mainHead":"Welcome to the world of",
            "mainHead1":"secure and online accounting"
        },
        "middle": {
        }
    }

    var rand = Math.random() * 4;
    window.onload = function () {
        alertMsg(parseInt(rand));
    }
    var alertMsg = function() {
        $timeout(alertMsg, 5000);
        var id = parseInt(Math.random()*3);
        var ele = angular.element( document.querySelector( '#tipscnt' ));
        switch (id) {
            case 0:
                ele.html('Tip : "Every transaction has a statement."');
                break;
            case 1:
                ele.html('Tip : "Your account book will never contain your name."');
                break;
            case 2:
                ele.html('Tip : "Every statement will have an entry."');
                break;
            case 3:
                ele.html('Tip : "Ateast two things will happen in every statement."');
                break;
            case 3:
                ele.html('Tip : "Accounting works on double entry system"');
                break;
        }
    }
    $timeout(alertMsg, 5000);

    $scope.loginWithGoogle=function() {
    };

    $scope.authenticate = function(provider) {
        $auth.authenticate(provider).then(function(response) {
            console.log(response, 'You have successfully created a new account');
        })
        .catch(function(response) {
          console.log(response);
        });
    }
    
}]);
