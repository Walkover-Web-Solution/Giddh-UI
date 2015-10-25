'use strict'

angular.module('giddhWebApp').service 'permissionService', () ->

  permissionService =
    hasPermissionOn: (entity , permissionCode) ->
      _.some(entity.role.permissions, (permission) ->
        permission.code is permissionCode
      )

  permissionService