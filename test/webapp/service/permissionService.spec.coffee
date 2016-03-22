'use strict'

describe "Permission Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @localStorageService = $injector.get('localStorageService')
      @permissionService = $injector.get('permissionService')

  describe "#searchCountry", ->
    it 'should Return true if user entity have given role and permission both', ->
      spyOn(@localStorageService, 'get').andReturn([{
        "name": "Admin", "uniqueName": "admin", "permissions": [{"code": "MNG_CMPNY", "description": "Manage Company"}]
      }])
      entity = {role: {"name": "Admin", "uniqueName": "admin"}}

      result = @permissionService.hasPermissionOn(entity, "MNG_CMPNY")
      expect(result).toBeTruthy()

    it 'should Return false if user entity does have given role but not permission', ->
      spyOn(@localStorageService, 'get').andReturn([{
        "name": "Admin", "uniqueName": "admin", "permissions": [{"code": "MNG_CMPNY", "description": "Manage Company"}]
      }])
      entity = {role: {"name": "Admin", "uniqueName": "admin"}}

      result = @permissionService.hasPermissionOn(entity, "OTHER")
      expect(result).toBeFalsy()

    it 'should Return false if user entity does not have given role', ->
      spyOn(@localStorageService, 'get').andReturn([{
        "name": "Admin", "uniqueName": "admin", "permissions": [{"code": "MNG_CMPNY", "description": "Manage Company"}]
      }])
      entity = {role: {"name": "view only", "uniqueName": "view_only"}}

      result = @permissionService.hasPermissionOn(entity, "MNG_CMPNY")
      expect(result).toBeFalsy()

    it 'should Return false roles is empty', ->
      spyOn(@localStorageService, 'get').andReturn([])
      entity = {role: {"name": "view only", "uniqueName": "view_only"}}

      result = @permissionService.hasPermissionOn(entity, "MNG_CMPNY")
      expect(result).toBeFalsy()

    it 'should Return false roles is undefined', ->
      spyOn(@localStorageService, 'get').andReturn(undefined )
      entity = {role: {"name": "view only", "uniqueName": "view_only"}}

      result = @permissionService.hasPermissionOn(entity, "MNG_CMPNY")
      expect(result).toBeFalsy()