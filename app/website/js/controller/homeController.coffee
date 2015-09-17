"use strict"

homeController = ($scope, $rootScope, $timeout) ->
  $scope.home =
    "banner":
      "mainHead": "Accounting is the foundation",
      "subHead": 'Accounting is the very first step of every successful business,\nstart using it today! You cannot build the foundation later.',
#      "p": "Giddh is an online accounting software for everyone",
      "imgSrc": "/public/website/images/screen.png",
      "imgTitle": "Giddh",
      "banBtnImgSrc": "/public/website/images/try.png",
      "banBtnImgTitle": "Try Now"
    "middle":
      "list": [
        {
          "title": "Pocket accounting - anytime, anywhere",
          "details": "Giddh is based on cloud computing. So it doesn't matter where you are, you can access your accounts anytime.",
          "imgSrc": "/public/website/images/online_on_cloud.png",
          "imgTitle": "Online on Cloud"
        },
        {
          "title": "No need to learn",
          "details": "The interface and functionality is so simple that you'll get familiar with Giddh in less than 10 minutes. Have a transaction in mind or on paper? Giddh it!",
          "imgSrc": "/public/website/images/no_need_to_learn.png",
          "imgTitle": "No need to learn"
        },
        {
          "title": "256 bit SSL Security",
          "details": "Your sensitive data is utmost secure with 256 bit SSL that is FIPS (Federal Information Processing Standard) certified – one of the strongest encryption methods out there.",
          "imgSrc": "/public/website/images/secure.png",
          "imgTitle": "Secure"
        },
        {
          "title": "Multi-user access",
          "details": "Your accounts can be managed by several admins, accountants, and even CA’s, that too in real time.\nAnd what’s fun is that entries can even be done OFF RECORD.",
          "imgSrc": "/public/website/images/multi_user.png",
          "imgTitle": "Multiple User"
        },
        {
          "title": "API's for everything",
          "details": "Still need to customize?\nGiddh offers you API's suiting your needs and requirements so that you can use them anywhere.",
          "imgSrc": "/public/website/images/apis_for_everything.png",
          "imgTitle": "Export"
        },
        {
          "title": "Search and export on the go",
          "details": "Search even the minute details and transactions with the easy to search feature. You can also download or export your accounting data in CSV or PDF as per your need and convenience.",
          "imgSrc": "/public/website/images/search_export_api.png",
          "imgTitle": "Search"
        },
        {
          "title": "Assistance in analysis",
          "details": "Giddh is not limited to transactions recording. It gives you immense help in analysis of your accounting data by providing you tools for it.",
          "imgSrc": "/public/website/images/assistance_in_analysis.png",
          "imgTitle": "Analysis"
        },
        {
          "title": "Benefits for start-ups",
          "details": "You have plenty of tasks other than maintaining accounts book, right?\nGo ahead and take up all the tasks that need your attention at first, because accounting is going to be easy with Giddh.",
          "imgSrc": "/public/website/images/benefits_for_startups.png",
          "imgTitle": "Benefits"
        }
      ]
    "bottomContent":
      "text": "Intuitive features with maximum simplicity makes accounting easy with",
      "imgSrc": "/public/website/images/backlogo.png",
      "altText": "Giddh"

  $scope.changeText = ->
    $timeout $scope.changeText, 30000
    id = parseInt(Math.random() * 2)
    switch id
      when 0
        $scope.home.banner.mainHead = 'Stuck in complex accounting?'
        $scope.home.banner.subHead = "Chuck it.\nGiddh isn't a math business. It's simple, intuitive and friendly.\nFrom big businesses to individuals, it's an online accounting software for everyone."
      when 1
        $scope.home.banner.mainHead = "Not 'only' for accountants!"
        $scope.home.banner.subHead = "Giddh is for people and businesses of all groups.\nWith a simple interface and a friendly design,\nyou'll never feel you are using an accounting software."
      when 2
        $scope.home.banner.mainHead = 'Backbone of a \nbusiness!'
        $scope.home.banner.subHead = "Analysis of income-expenses, management of transactions \nand statement of profit-loss is a necessity. \nAnd it's a simple and user-firendly task with Giddh."
    return
  $timeout($scope.changeText, 30000)

angular.module('giddhApp').controller 'homeController', homeController