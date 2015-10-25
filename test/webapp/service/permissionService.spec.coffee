'use strict'

describe "Permission Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @permissionService = $injector.get('permissionService')

  describe "#searchCountry", ->
    it 'should Return true if user entity have given permission', ->
      entity = {role: {permissions: [{code: "VW"}, {code: "EDT"}, {code: "MNG_USR"}]}}

      result = @permissionService.hasPermissionOn(entity, "MNG_USR")
      expect(result).toBeTruthy()

    it 'should Return false if user entity does not have given permission', ->
      entity = {role: {permissions: [{code: "VW"}, {code: "EDT"}, {code: "MNG_USR"}]}}

      result = @permissionService.hasPermissionOn(entity, "OTHER")
      expect(result).toBeFalsy()