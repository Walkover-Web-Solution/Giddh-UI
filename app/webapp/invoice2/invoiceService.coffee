'use strict'

giddh.serviceModule.service 'invoiceService', ($resource, $q) ->
  Invoice = $resource('/company/:companyUniqueName/invoices',
    {
      'companyUniqueName': @companyUniqueName
      'date1': @date1
      'date2': @date2
      'combined': @combined
      'invoiceUniqueName': @invoiceUniqueName
    },
    {
      getAll: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices?from=:date1&to=:date2'
      }
      getAllLedgers: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/ledgers?from=:date1&to=:date2'
      }
      generateBulkInvoice: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/bulk-generate?combined=:combined'
      }
      actionOnInvoice: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/action'
      }
    })

  invoiceService =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getInvoices: (info, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.getAll({
        companyUniqueName: info.companyUniqueName
        date1: info.fromDate
        date2: info.toDate
        count: info.count
        page: info.page
      }, data, onSuccess, onFailure))

    getAllLedgers: (info, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.getAllLedgers({
        companyUniqueName: info.companyUniqueName
        date1: info.fromDate
        date2: info.toDate
        count: info.count
        page: info.page
      },data, onSuccess, onFailure))

    generateBulkInvoice: (info, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.generateBulkInvoice({
        companyUniqueName: info.companyUniqueName
        combined: info.combined
      }, data, onSuccess, onFailure))

    performAction: (info, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.actionOnInvoice({
        companyUniqueName: info.companyUniqueName
        invoiceUniqueName: info.invoiceUniqueName
      }, data, onSuccess, onFailure))

  invoiceService