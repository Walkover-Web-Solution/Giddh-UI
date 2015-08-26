(function() {
  'use strict';
  var contactController;

  contactController = function($scope, $rootScope, $http, $timeout) {
    $scope.contact = {
      "banner": {
        "mainHead": "support",
        "mainHead1": "@giddh.com",
        "subHead": "I would love to read you. I have some guys who are reading your emails day and night for the support, feature request, press or sales.",
        "banBtnImgSrc": "/views/images/try.png",
        "banBtnImgTitle": "Try Now"
      },
      "middle": {
        "formHead": "You can email me",
        "title": "Get In Touch",
        "socialTitle": "Connect with us:",
        "socialList": [
          {
            "name": "Google",
            "url": "javascript:void(0)",
            "class": "gplus"
          }, {
            "name": "Facebook",
            "url": "http://www.facebook.com/giddh",
            "class": "fb"
          }, {
            "name": "Linkedin",
            "url": "javascript:void(0)",
            "class": "in"
          }, {
            "name": "Twitter",
            "url": "https://twitter.com/giddhcom/",
            "class": "twit"
          }, {
            "name": "Youtube",
            "url": "http://www.youtube.com/watch?v=p6HClX7mMMY",
            "class": "yt"
          }, {
            "name": "RSS",
            "url": "http://blog.giddh.com/feed/",
            "class": "rss"
          }
        ]
      }
    };
    $scope.hasWhiteSpace = function(s) {
      return /\s/g.test(s);
    };
    $scope.form = {};
    $scope.integerval = /^\d*$/;
    return $scope.submitForm = function() {
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
          details.uFname = $scope.user.name;
        }
        return $http.post('http://localhost:8000/submitContactDetail', {
          uFname: details.uFname,
          uLname: details.uLname,
          email: $scope.user.email,
          number: $scope.user.number,
          msg: $scope.user.msg
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

  angular.module('giddhApp').controller('contactController', contactController);

}).call(this);
