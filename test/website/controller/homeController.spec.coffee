'use strict'

describe 'homeController', ->
  beforeEach module("giddhApp")

  beforeEach inject ($rootScope, $controller) ->
    @scope = $rootScope.$new()
    @homeController = $controller('homeController',
      {$scope: @scope})

  describe "#changeText", ->
    it 'should goes in 0 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(0.4)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Stuck in complex accounting?")
      expect(@scope.home.banner.subHead).toEqual("Chuck it.\nGiddh isn't a math business. It's simple, intuitive and friendly.\nFrom big businesses to individuals, it's an online accounting software for everyone.")

    it 'should goes in 1 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(0.5)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Not 'only' for accountants!")
      expect(@scope.home.banner.subHead).toEqual("Giddh is for people and businesses of all groups.\nWith a simple interface and a friendly design,\nyou'll never feel you are using an accounting software.")

    it 'should goes in 2 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(1.2)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Backbone of a \nbusiness!")
      expect(@scope.home.banner.subHead).toEqual("Analysis of income-expenses, management of transactions \nand statement of profit-loss is a necessity. \nAnd it's a simple and user-firendly task with Giddh.")