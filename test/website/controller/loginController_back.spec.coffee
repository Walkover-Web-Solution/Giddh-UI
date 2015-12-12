'use strict'

describe 'loginBackController', ->
  beforeEach module("giddhApp")
  beforeEach inject ($rootScope, $controller, loginService) ->
    @scope = $rootScope.$new()
    @loginService = loginService
    @loginBackController = $controller('loginBackController',
      {$scope: @scope})

