'use strict'

describe 'companyController', ->
  beforeEach module('giddhApp')

  beforeEach inject ($rootScope, $controller) ->
    @scope = $rootScope.$new()
    @companyController = $controller('companyController',
        {$scope: @scope})