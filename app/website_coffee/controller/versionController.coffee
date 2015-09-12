'use strict'

versionController = ($scope, $rootScope, $http, $timeout) ->
  $scope.version = 
    "banner": 
      "mainHead":"Giddh",
      "mainHead1":"VERSION 2",
      "subHead":"Features are never ending but important thing is that we bring the most important feature for you with the same simplicity. Here are few most exciting features coming in Giddh version 2.",
      "banBtnImgSrc":"/views/images/try.png",
      "banBtnImgTitle":"Try Now"
    "middle": 
      "list":[
          {
              "title" : "Share",
              "details" : "Not only company, you can share an individual account too. This will give you and your party better clarity and accountability to understand the accounts."
          },
          {
              "title" : "Grouping of companies",
              "details" : "You may call it branch or your department, What if you want to analyse your product separately and at the same time, bring them together to see as big picture? This could be the only way or the best way."
          },
          {
              "title" : "Chrome and Android App",
              "details" : "Internet is fantastic, but what if you can’t get access to it when you need to make an entry. Chrome and Android App has sync facility so that your transactions will never be missed and it will be in real time always."
          }
      ]
        
    

angular.module('giddhApp').controller 'versionController', versionController