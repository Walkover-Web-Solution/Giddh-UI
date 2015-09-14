'use strict'

describe 'homeController', ->
  beforeEach module("giddhApp")

  beforeEach inject ($rootScope, $controller) ->
    @scope = $rootScope.$new()
    @homeController = $controller('homeController',
      {$scope: @scope})

  describe "#hospitals", ->
    it 'should run', ->
      expect(1).toEqual(1)