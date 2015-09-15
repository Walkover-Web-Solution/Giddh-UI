'use strict'

contactController = ($scope, $rootScope, $http) ->
  $scope.contact =
    "banner":
      "mainHead": "support",
      "mainHead1": "@giddh.com",
      "subHead": "I would love to read you. I have some guys who are reading your emails day and night for the support, feature request, press or sales.",
      "banBtnImgSrc": "/public/website/images/try.png",
      "banBtnImgTitle": "Try Now"
    "middle":
      "formHead": "You can email me",
      "title": "Get In Touch",
      "socialTitle": "Connect with us:",
      "socialList": [
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
  # check string has whitespace
  $scope.hasWhiteSpace = (s) ->
    return /\s/g.test(s)
  $scope.form = {}
  $scope.integerval = /^\d*$/
  # function to submit the form after all validation has occurred

  $scope.submitForm = ->
    $scope.responseMsg = "loading... Submitting Form"
    # check to make sure the form is completely valid
    if $scope.form.$valid
      details = []
      #check and split full name in first and last name
      if($scope.hasWhiteSpace($scope.user.name))
        unameArr = $scope.user.name.split(" ")
        details.uFname = unameArr[0]
        details.uLname = unameArr[1]
      else
        details.uFname = $scope.user.name
        details.uLname = "  "

      $http.post('http://localhost:8000/submitContactDetail',
        uFname: details.uFname
        uLname: details.uLname
        email: $scope.user.email
        number: $scope.user.number
        msg: $scope.user.msg
      ).then((response) ->
        if(response.status == 200)
          $scope.blank = {}
          $scope.user = angular.copy($scope.blank)
          $scope.form.$setPristine()

          if(angular.isUndefined(response.data.message))
            $scope.responseMsg = "Thanks! will get in touch with you soon"
          else
            $scope.responseMsg = response.data.message)

angular.module('giddhApp').controller 'contactController', contactController
