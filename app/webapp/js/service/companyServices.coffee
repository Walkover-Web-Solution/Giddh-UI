'use strict'

angular.module('giddhWebApp').service 'companyServices', ($resource, $q) ->
  Company = $resource('/company', {'uniqueName': @uniqueName}, {
    addCompany: {method: 'POST'}
    getCompanyDetails: {method: 'GET', url: '/company/:uniqueName'}
    getCompanyList: {method: 'GET', url: '/company/all'}
    deleteCompany: {method: 'DELETE', url: '/company/:uniqueName'}
    updateCompany: {method: 'PUT', url: '/company/:uniqueName'}
    shareCompany: {method: 'PUT', url: '/company/:uniqueName/share'}
    getSharedList: {method: 'GET', url: '/company/:uniqueName/shared-with'}
    getCmpRolesList: {method: 'GET', url: '/company/:uniqueName/shareable-roles'}
    unSharedUser: {method: 'PUT', url: '/company/:uniqueName/unshare'}
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

  companyServices