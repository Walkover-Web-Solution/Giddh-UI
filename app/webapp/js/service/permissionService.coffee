'use strict'

giddh.serviceModule.service 'permissionService', (localStorageService) ->
  permissionService =
    hasPermissionOn: (entity, permissionCode) ->
      #console.log entity
      roles = localStorageService.get("_roles")
      if(_.isUndefined(roles) or _.isEmpty(roles))
        return false
      role = _.find roles, (role) ->
        role.uniqueName is entity.role.uniqueName
      if(_.isUndefined(role) or _.isEmpty(role))
        return false
      _.some(role.permissions, (permission) ->
        permission.code is permissionCode
      )

  permissionService