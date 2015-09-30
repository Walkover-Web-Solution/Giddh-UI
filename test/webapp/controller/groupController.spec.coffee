'use strict'

describe 'groupController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @localStorageService = localStorageService
    @groupController = $controller('groupController',
        {$scope: @scope, $rootScope: @rootScope, localStorageService: @localStorageService})

  describe '#getGroups', ->
    it 'should check for selected company from local storage and set a local variable', ->
      spyOn(@localStorageService,'keys').andReturn({"_selectedCompany"})
      spyOn(@localStorageService,'get').andReturn({"data":"Got it"})
      @scope.getGroups()
      expect(@scope.companyBasicInfo).toBe({"data":"Got it"})