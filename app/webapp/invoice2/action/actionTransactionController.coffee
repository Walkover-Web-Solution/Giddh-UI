'use strict'

actionTransactionController = ($scope, $rootScope, invoicePassed, invoiceService, toastr) ->

  $scope.invoiceSelected = invoicePassed
  $scope.getTransactionList = () ->
    @success = (res) ->
      $scope.getAllInvoices()
      $scope.modalInstance.close()
    @failure = (res) ->
      toastr.error(res.data.message)
    infoToSend = {
      companyUniqueName: $rootScope.selectedCompany.uniqueName
      invoiceUniqueName: $scope.invoiceSelected.uniqueName
    }
    dataToSend = {
      amount: $scope.invoiceSelected.balanceDue
      action: 'paid'
    }
    invoiceService.performAction(infoToSend, dataToSend).then(@success, @failure)


giddh.webApp.controller 'actionTransactionController', actionTransactionController