'use strict'

giddh.serviceModule.service 'permissionService', (localStorageService) ->
  permissionService =
    hasPermissionOn: (entity, permissionCode) ->
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

    shareableRoles: (selectedCompany) ->
      roles = localStorageService.get("_roles")
      roleOnCompany = _.find roles, (role) ->
        role.uniqueName is selectedCompany.role.uniqueName
      if _.isUndefined(roleOnCompany)
        return

      allowableRoles = _.filter roles, (role) ->
        _.every role.permissions, (permission) ->
          _.contains (_.pluck roleOnCompany.permissions, 'code'), permission.code

  permissionService