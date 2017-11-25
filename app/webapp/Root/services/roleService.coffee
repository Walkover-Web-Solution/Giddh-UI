'use strict'

giddh.serviceModule.service 'roleServices', ($resource, $q) ->
  Role = $resource('/roles', {}
    {
      all: {
        method: 'GET'
      }
      getEnvVar:{
        method: 'GET'
        url: '/roles/getEnvVars'
      }
    }
  )

  permissionRoles = $resource('/company/:companyUniqueName/role',
    {
      'companyUniqueName': @companyUniqueName
      'roleUniqueName': @roleUniqueName
    },
    {
      getAllRolesOfCompany:
        method: 'GET'
        url: '/company/:companyUniqueName/role/'
      assign:
        method: 'POST'
        url: '/company/:companyUniqueName/role/:roleUniqueName/assign'
      revoke:
        method: 'POST'
        # url: '/company/:companyUniqueName/role/:roleUniqueName/revoke'
        url: '/company/:companyUniqueName/uer/:roleUniqueName'
    })

  roleServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    getAll: (compUname) ->
      @handlePromise((onSuccess,  onFailure) -> permissionRoles.getAllRolesOfCompany({
        companyUniqueName: compUname}, onSuccess, onFailure))

    getEnvVars: () ->
      @handlePromise((onSuccess, onFailure) -> Role.getEnvVar(onSuccess, onFailure))

    share: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> permissionRoles.assign({
        companyUniqueName: unqNamesObj.compUname,
        roleUniqueName: unqNamesObj.roleUname
      }, data, onSuccess, onFailure))

    unshare: (unqNamesObj, data) ->
      @handlePromise((onSuccess, onFailure) -> permissionRoles.revoke({
        companyUniqueName: unqNamesObj.compUname,
        roleUniqueName: unqNamesObj.roleUname
      }, data, onSuccess, onFailure))

  roleServices