'use strict'

giddh.serviceModule.service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', 
  {
    'uniqueName': @uniqueName
    'page': @page
    'tempUname': @tempUname
    'invoiceUniqueID': @invoiceUniqueID
    'taxUniqueName': @taxUniqueName
    'to':@to
    'from':@from
  },
  {
    addCompany:
      method: 'POST'

    getStates:
      method: 'GET'
      url: '/company/states'
    
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

    saveSmsKey:
      method: 'POST'
      url: '/company/:companyUniqueName/sms-key'

    saveEmailKey:
      method: 'POST'
      url: '/company/:companyUniqueName/email-key'

    getSmsKey:
      method: 'GET'
      url: '/company/:companyUniqueName/sms-key'

    getEmailKey:
      method: 'GET'
      url: '/company/:companyUniqueName/email-key'

    sendEmail:
      method: 'POST'
      url: '/company/:companyUniqueName/accounts/bulk-email?from=:from&to=:to'

    sendSms:
      method: 'POST'
      url: '/company/:companyUniqueName/accounts/bulk-sms?from=:from&to=:to'

    getFY:
      method: 'GET'
      url: '/company/:companyUniqueName/financial-year'

    updateFY:
      method: 'PUT'
      url: '/company/:companyUniqueName/financial-year'

    switchFY:
      method: 'PATCH'
      url: '/company/:companyUniqueName/active-financial-year'

    lockFY:
      method: 'PATCH'
      url: '/company/:companyUniqueName/financial-year-lock'

    unlockFY:
      method: 'PATCH'
      url: '/company/:companyUniqueName/financial-year-unlock'

    addFY:
      method: 'POST'
      url: '/company/:companyUniqueName/financial-year'

    getMagicLink:
      method: 'POST'
      url: '/company/:companyUniqueName/accounts/:accountUniqueName/magic-link?from=:from&to=:to'

    assignTax:
      method: 'POST'
      url: '/company/:companyUniqueName/tax/assign'

    saveInvoiceSetting:
      method: 'PUT'
      url: '/company/:companyUniqueName/invoice-setting'

    getCroppedAcnt:
      method: 'GET'
      url: '/company/:companyUniqueName/cropped-flatten-account'

    postCroppedAcnt:
      method: 'POST'
      url: '/company/:companyUniqueName/cropped-flatten-account'
       

    getAllSettings:
      method: 'GET'
      url: '/company/:companyUniqueName/settings'

    updateAllSettings:
      method: 'PUT'
      url: '/company/:companyUniqueName/settings'

    createWebhook:
      method: 'POST'
      url: '/company/:companyUniqueName/settings/webhooks'

    deleteWebhook:
      method: 'DELETE'
      url: '/company/:companyUniqueName/settings/webhooks/:webhookUniqueName'

    getRazorPayDetail:
      method: 'GET'
      url: '/company/:companyUniqueName/razorpay'

    addRazorPayDetail:
      method: 'POST'
      url: '/company/:companyUniqueName/razorpay'

    updateRazorPayDetail:
      method: 'PUT'
      url: '/company/:companyUniqueName/razorpay'

    deleteRazorPayDetail:
      method: 'DELETE'
      url: '/company/:companyUniqueName/razorpay'
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

    getStates: () ->
      @handlePromise((onSuccess, onFailure) -> Company.getStates( onSuccess, onFailure))

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

    saveSmsKey: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.saveSmsKey({companyUniqueName: companyUniqueName}, data, onSuccess, onFailure))

    saveEmailKey: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.saveEmailKey({companyUniqueName: companyUniqueName}, data, onSuccess, onFailure))

    getSmsKey: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getSmsKey({companyUniqueName: companyUniqueName}, onSuccess,
          onFailure))

    getEmailKey: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getEmailKey({companyUniqueName: companyUniqueName}, onSuccess,
          onFailure))

    sendEmail: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.sendEmail({companyUniqueName: reqParam.compUname, to:reqParam.to, from:reqParam.from}, data, onSuccess, onFailure))

    sendSms: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.sendSms({companyUniqueName: reqParam.compUname, to:reqParam.to, from:reqParam.from}, data, onSuccess, onFailure))

    getFY: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getFY({companyUniqueName: companyUniqueName}, onSuccess,
          onFailure))

    updateFY: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.updateFY({companyUniqueName: reqParam.companyUniqueName}, data, onSuccess, onFailure))

    switchFY: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.switchFY({companyUniqueName: reqParam.companyUniqueName}, data, onSuccess, onFailure))

    lockFY: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.lockFY({companyUniqueName: reqParam.companyUniqueName}, data, onSuccess, onFailure))

    unlockFY: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.unlockFY({companyUniqueName: reqParam.companyUniqueName}, data, onSuccess, onFailure))

    addFY: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.addFY({companyUniqueName: reqParam.companyUniqueName}, data, onSuccess, onFailure))

    getMagicLink: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.getMagicLink({companyUniqueName: reqParam.companyUniqueName, accountUniqueName: reqParam.accountUniqueName, from:reqParam.from, to:reqParam.to}, data, onSuccess, onFailure))

    assignTax: (companyUniqueName,data) ->
      @handlePromise((onSuccess, onFailure) -> Company.assignTax({
        companyUniqueName: companyUniqueName
      },data, onSuccess, onFailure))

    saveInvoiceSetting: (companyUniqueName,data) ->
      @handlePromise((onSuccess, onFailure) -> Company.saveInvoiceSetting({
        companyUniqueName: companyUniqueName
      },data, onSuccess, onFailure))

    getCroppedAcnt: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.getCroppedAcnt({
        companyUniqueName: reqParam.cUname,
        query: reqParam.query
      },data, onSuccess, onFailure))

    postCroppedAcnt: (reqParam, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.postCroppedAcnt({
        companyUniqueName: reqParam.cUname,
        query: reqParam.query
      },data, onSuccess, onFailure))


    getAllSettings: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getAllSettings({
        companyUniqueName: companyUniqueName
      }, onSuccess, onFailure))

    updateAllSettings: (companyUniqueName,data) ->
      @handlePromise((onSuccess, onFailure) -> Company.updateAllSettings({
        companyUniqueName: companyUniqueName
      },data, onSuccess, onFailure))

    createWebhook: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.createWebhook({
        companyUniqueName: companyUniqueName
      }, data, onSuccess, onFailure))

    deleteWebhook: (companyUniqueName, webhookUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.deleteWebhook({
        companyUniqueName: companyUniqueName
        webhookUniqueName: webhookUniqueName
      }, onSuccess, onFailure))

    getRazorPay: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.getRazorPayDetail({
        companyUniqueName: companyUniqueName
      }, onSuccess, onFailure))

    addRazorPay: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.addRazorPayDetail({
        companyUniqueName: companyUniqueName
      }, data, onSuccess, onFailure))

    updateRazorPay: (companyUniqueName, data) ->
      @handlePromise((onSuccess, onFailure) -> Company.updateRazorPayDetail({
        companyUniqueName: companyUniqueName
      }, data, onSuccess, onFailure))

    deleteRazorPay: (companyUniqueName) ->
      @handlePromise((onSuccess, onFailure) -> Company.deleteRazorPayDetail({
        companyUniqueName: companyUniqueName
      }, onSuccess, onFailure))

  companyServices

