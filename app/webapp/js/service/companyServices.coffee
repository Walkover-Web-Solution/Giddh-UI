'use strict'

giddh.serviceModule.service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', 
  {
    'uniqueName': @uniqueName
    'page': @page
    'tempUname': @tempUname
    'invoiceUniqueID': @invoiceUniqueID
    'taxUniqueName': @taxUniqueName
  },
  {
    addCompany:
      method: 'POST'
    
    getCompanyDetails:
      method: 'GET'
      url: '/company/:uniqueName'

    getCompanyList:
      method: 'GET'
      url: '/company/all'

    deleteCompany:
      method: 'DELETE'
      url: '/company/:uniqueName'

    updateCompany:
      method: 'PUT'
      url: '/company/:uniqueName'

    shareCompany:
      method: 'PUT'
      url: '/company/:uniqueName/share'

    getSharedList:
      method: 'GET'
      url: '/company/:uniqueName/shared-with'

    getCmpRolesList:
      method: 'GET'
      url: '/company/:uniqueName/shareable-roles'

    unSharedUser:
      method: 'PUT'
      url: '/company/:uniqueName/unshare'

    getUploadListDetails:
      method: 'GET'
      url: '/company/:uniqueName/imports'
    
    getProfitLoss:
      method:'GET'
      url: '/company/:uniqueName/profit-loss'

    switchUser:
      method: 'GET'
      url: '/company/:uniqueName/switchUser'

    getCompTrans:
      method:'GET'
      url: '/company/:uniqueName/transactions?page=:page'
    
    updtCompSubs:
      method: 'PUT'
      url: '/company/:uniqueName/subscription-update'
    
    payBillViaWallet:
      method: 'POST'
      url: '/company/:uniqueName/pay-via-wallet'
    
    retryXmlUpload:
      method: 'PUT'
      url: '/company/:uniqueName/retry'
    
    getInvTemplates:
      method: 'GET'
      url: '/company/:uniqueName/templates'

    setDefltInvTemplt:
      method: 'PUT'
      url: '/company/:uniqueName/templates/:tempUname'

    updtInvTempData:
      method: 'PUT'
      url: '/company/:uniqueName/templates'

    delInv:
      method: 'DELETE'
      url: '/company/:uniqueName/invoices/:invoiceUniqueID'
    
    getTax:
      method:'GET'
      url: '/company/:uniqueName/tax'
    
    addTax:
      method: 'POST'
      url: '/company/:uniqueName/tax'
    
    deleteTax:
      method: 'DELETE',
      url: '/company/:uniqueName/tax/:taxUniqueName'
    
    editTax:
      method: 'PUT'
      url: '/company/:uniqueName/tax/:taxUniqueName/:updateEntries'

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

    share: (uniqueName, shareRequest, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.shareCompany({
        uniqueName: uniqueName
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

    getPL :(obj) ->
      @handlePromise((onSuccess, onFailure) -> Company.getProfitLoss({uniqueName: obj.uniqueName, from: obj.fromDate, to:obj.toDate}, onSuccess, onFailure))

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

    getInvTemplates: (uniqueName, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.getInvTemplates({uniqueName: uniqueName}, onSuccess, onFailure))

    setDefltInvTemplt: (obj, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.setDefltInvTemplt({uniqueName: obj.uniqueName, tempUname: obj.tempUname}, {}, onSuccess, onFailure))

    updtInvTempData: (uniqueName, data, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.updtInvTempData({uniqueName: uniqueName}, data, onSuccess, onFailure))

    delInv: (obj, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.delInv({
          uniqueName: obj.compUname
          invoiceUniqueID: obj.invoiceUniqueID
        }, onSuccess, onFailure))

    getTax: (uniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getTax({uniqueName: uniqueName}, onSuccess, onFailure))

    addTax: (uniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.addTax({uniqueName: uniqueName}, data, onSuccess, onFailure))

    deleteTax : (reqParam, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.deleteTax({
        uniqueName: reqParam.uniqueName
        taxUniqueName: reqParam.taxUniqueName
      }, onSuccess, onFailure))
    
    editTax: (reqParam, taxData, onSuccess, onFailure) ->
      @handlePromise((onSuccess, onFailure) -> Company.editTax({
        uniqueName: reqParam.uniqueName
        taxUniqueName: reqParam.taxUniqueName
        updateEntries: reqParam.updateEntries
      }, taxData, onSuccess, onFailure))

  companyServices