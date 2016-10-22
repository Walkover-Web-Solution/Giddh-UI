'use strict'

giddh.serviceModule.service 'invoiceService', ($resource, $q) ->
  Invoice = $resource('/company/:companyUniqueName/invoices',
    {
      'companyUniqueName': @companyUniqueName
      'date1': @date1
      'date2': @date2
    },
    {
      getAll: {
        method: 'GET'
        url: '/company/:companyUniqueName/invoices?from=:date1&to=:date2'
      }
    })

  invoiceService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getInvoices: (info) ->
      console.log(info)
      @handlePromise((onSuccess, onFailure) -> Invoice.getAll({
        companyUniqueName: info.companyUniqueName
        date1: info.fromDate
        date2: info.toDate
      }, info, onSuccess, onFailure))

  invoiceService