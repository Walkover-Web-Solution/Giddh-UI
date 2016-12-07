'use strict'

giddh.serviceModule.service 'invoiceService', ($resource, $q) ->
  Invoice = $resource('/company/:companyUniqueName/invoices',
    {
      'companyUniqueName': @companyUniqueName
      'date1': @date1
      'date2': @date2
      'combined': @combined
      'proforma': @proforma
      'count':@count
      'page':@page
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
      getAllProforma: {
        method: 'GET'
        url: '/company/:companyUniqueName/invoices/proforma/all?from=:date1&to=:date2&count=:count&page=:page'
      }
      getAllProformaByFilter: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/proforma/all'
      }
      deleteProforma: {
        method: 'DELETE'
        url: '/company/:companyUniqueName/invoices/proforma/delete'
      }
      updateBalanceStatus: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/proforma/updateBalanceStatus'
      }
      linkProformaAccount: {
        method: 'POST'
        url: '/company/:companyUniqueName/invoices/proforma/link-account'
      }
      getTemplates: {
        method: 'GET'
        url: '/company/:companyUniqueName/invoices/proforma/templates'
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

    getAllProforma: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.getAllProforma({
        companyUniqueName: reqParam.companyUniqueName
        date1: reqParam.date1
        date2: reqParam.date2
        count: reqParam.count
        page : reqParam.page
      }, onSuccess, onFailure))

    getAllProformaByFilter: (company, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.getAllProformaByFilter({
        companyUniqueName: company
      }, data, onSuccess, onFailure))

    deleteProforma: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.deleteProforma({
        companyUniqueName: reqParam.companyUniqueName
        proforma: reqParam.proforma
      }, onSuccess, onFailure))

    updateBalanceStatus: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.updateBalanceStatus({
        companyUniqueName: reqParam.companyUniqueName
      }, data, onSuccess, onFailure))

    linkProformaAccount: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.linkProformaAccount({
        companyUniqueName: reqParam.companyUniqueName
      }, data, onSuccess, onFailure))

    getTemplates: (reqParam) ->
      @handlePromise((onSuccess, onFailure) -> Invoice.getTemplates({
        companyUniqueName: reqParam.companyUniqueName
      }, onSuccess, onFailure))


  invoiceService