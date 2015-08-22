'use strict'

contactController = ($scope, $rootScope, $http, $timeout) ->
  $scope.contact = 
    "banner": 
        "mainHead":"support",
        "mainHead1":"@giddh.com",
        "subHead":"I would love to read you. I have some guys who are reading your emails day and night for the support, feature request, press or sales.",
        "banBtnImgSrc":"/views/images/try.png",
        "banBtnImgTitle":"Try Now"
    "middle":
      "formHead":"You can email me",
      "title":"Get In Touch",
      "socialTitle" : "Connect with us:",
      "socialList" : [
        {
            "name": "Google",
            "url": "javascript:void(0)",
            "class": "gplus"
        },
        {
            "name": "Facebook",
            "url": "http://www.facebook.com/giddh",
            "class": "fb"
        },
        {
            "name": "Linkedin",
            "url": "javascript:void(0)",
            "class": "in"
        },
        {
            "name": "Twitter",
            "url": "https://twitter.com/giddhcom/",
            "class": "twit"
        },
        {
            "name": "Youtube",
            "url": "http://www.youtube.com/watch?v=p6HClX7mMMY",
            "class": "yt"
        },
        {
            "name": "RSS",
            "url": "http://blog.giddh.com/feed/",
            "class": "rss"
        }
      ]
  $scope.form = {}
  $scope.integerval = /^\d*$/
  # function to submit the form after all validation has occurred  

  $scope.submitForm = ->
    # check to make sure the form is completely valid
    if $scope.form.$valid
      console.log $scope.form
      htmlBody = '<div>Name: ' + $scope.form.uEmail.$viewValue + '</div>' + '<div>Email: ' + $scope.form.uNumber.$viewValue + '</div>' + '<div>Email: ' + $scope.form.uEmail.$viewValue + '</div>' + '<div>Message: ' + $scope.form.uMessage.$viewValue + '</div>' + '<div>Date: ' + (new Date).toString() + '</div>'
      console.log 'our form is amazing', htmlBody
    return

angular.module('giddhApp').controller 'contactController', contactController
