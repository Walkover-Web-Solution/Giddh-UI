'use strict'

loginController = ($scope, $rootScope, $http, $timeout, $location) ->

  #webpage data
  $scope.login = 'banner':
    'mainHead': 'Uh, oh!'
    'mainHead1': 'You can\'t go through because the app is invitation only.'

  $scope.form = {}
  
  # check string has whitespace
  $scope.hasWhiteSpace  = (s) ->
    return /\s/g.test(s);

  $scope.submitUserForm = ->
    if $scope.form.$valid

      details = [];
      #check and split full name in first and last name
      if($scope.hasWhiteSpace($scope.user.name))
        console.log("dude you rock")
        unameArr = $scope.user.name.split(" ");
        details.uFname = unameArr[0]
        details.uLname = unameArr[1]
      else 
        details.uFname = $scope.user.name
        details.uLname = "   "



      $http.post('/submitBetaInviteDetails',
        uFname: details.uFname
        uLname: details.uLname
        email: $scope.user.email
        company: $scope.user.company
        reason: $scope.user.reason).then ((response) ->
          console.log 'then', response
          if(response.status == 200)
            $scope.blank = {}
            $scope.user = angular.copy($scope.blank)
            $scope.form.$setPristine()
            if(angular.isUndefined(response.data.message))
              $scope.responseMsg = "Thanks! will get in touch with you soon"
            else
              $scope.responseMsg = response.data.message
        ),(response) ->
          console.log 'in response', response

angular.module('giddhApp').controller 'loginController', loginController