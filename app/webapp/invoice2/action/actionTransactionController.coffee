'use strict'

actionTransactionController = ($scope, $rootScope, invoicePassed, ledgerService) ->
  $scope.getTransactionList = () ->
    console.log("here we have to get all transactions")
    console.log(invoicePassed)

  $scope.getTransactionList()


giddh.webApp.controller 'actionTransactionController', actionTransactionController