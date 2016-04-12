'use strict'

giddh.serviceModule.service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', {
    'uniqueName': @uniqueName
    'page': @page
    },{
    addCompany: {method: 'POST'}
    getCompanyDetails: {method: 'GET', url: '/company/:uniqueName'}
    getCompanyList: {method: 'GET', url: '/company/all'}
    deleteCompany: {method: 'DELETE', url: '/company/:uniqueName'}
    updateCompany: {method: 'PUT', url: '/company/:uniqueName'}
    shareCompany: {method: 'PUT', url: '/company/:uniqueName/share'}
    getSharedList: {method: 'GET', url: '/company/:uniqueName/shared-with'}
    getCmpRolesList: {method: 'GET', url: '/company/:uniqueName/shareable-roles'}
    unSharedUser: {method: 'PUT', url: '/company/:uniqueName/unshare'}
    getUploadListDetails: {method: 'GET', url: '/company/:uniqueName/imports'}
    getProfitLoss: {method:'GET', url: '/company/:companyUniqueName/profit-loss'}
    switchUser: {method: 'GET', url: '/company/:uniqueName/switchUser'}

    getCompTrans: {
      method:'GET'
      url: '/company/:uniqueName/transactions?page=:page'
    }
    updtCompSubs: {
      method: 'PUT'
      url: '/company/:uniqueName/subscription-update'
    }
    payBillViaWallet: {
      method: 'POST'
      url: '/company/:uniqueName/pay-via-wallet'
    }
    retryXmlUpload: {
      method: 'PUT'
      url: '/company/:uniqueName/retry'
    }
  })

  companyServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    create: (cdata) ->
      @handlePromise((onSuccess, onFailure) -> Company.addCompany(cdata, onSuccess, onFailure))

    getAll: () ->
      @handlePromise((onSuccess, onFailure) -> Company.getCompanyList(onSuccess, onFailure))

    get: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getCompanyDetails({uniqueName: uniqueName}, onSuccess,
          onFailure))

    delete: (uniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.deleteCompany({
        uniqueName: uniqueName
      }, onSuccess, onFailure))

    update: (updtData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.updateCompany({
        uniqueName: updtData.uniqueName
      }, updtData, onSuccess, onFailure))

    share: (companyUniqueName, shareRequest, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.shareCompany({
        uniqueName: companyUniqueName
      }, shareRequest, onSuccess, onFailure))

    shredList: (uniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) ->
        Company.getSharedList({uniqueName: uniqueName}, onSuccess, onFailure))

    unSharedComp: (uniqueName, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) ->
        Company.unSharedUser({uniqueName: uniqueName}, data, onSuccess, onFailure))

    getRoles: (cUname, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) ->
        Company.getCmpRolesList({uniqueName: cUname}, onSuccess, onFailure))

    getUploadsList: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getUploadListDetails({uniqueName: uniqueName}, onSuccess, onFailure))

    getPL :(reqParam) ->
      @handlePromise((onSuccess, onFailure) -> Company.getProfitLoss({companyUniqueName: reqParam.companyUniqueName, from: reqParam.fromDate, to:reqParam.toDate}, onSuccess, onFailure))

    getCompTrans: (obj) ->
      @handlePromise((onSuccess, onFailure) -> Company.getCompTrans({uniqueName: obj.name, page: obj.num}, onSuccess, onFailure))

    updtCompSubs: (data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.updtCompSubs({
        uniqueName: data.uniqueName
      }, data, onSuccess, onFailure))
      
    payBillViaWallet: (data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.payBillViaWallet({
        uniqueName: data.uniqueName
      }, data, onSuccess, onFailure))

    retryXml: (uniqueName, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.retryXmlUpload({uniqueName: uniqueName},data, onSuccess, onFailure))

    switchUser: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.switchUser({uniqueName: uniqueName},onSuccess,
          onFailure))

  companyServices