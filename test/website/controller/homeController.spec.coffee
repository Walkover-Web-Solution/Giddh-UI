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
      spyOn(Math, "random").andReturn(0.1)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Analyse BIG \nDATA")
      expect(@scope.home.banner.subHead).toEqual("Accounting is nothing but keeping your transactions in an efficient way. Your eyes could have limitations; let me show you everything in one shot.")

    it 'should goes in 1 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(0.3)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Stuck in complex accounting?")
      expect(@scope.home.banner.subHead).toEqual("Chuck it.\nGiddh isn't a math business. It's simple, intuitive and friendly.\nFrom big businesses to individuals, it's an online accounting software for everyone.")

    it 'should goes in 2 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(0.5)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Not 'only' for accountants!")
      expect(@scope.home.banner.subHead).toEqual("Giddh is for people and businesses of all groups.\nWith a simple interface and a friendly design,\nyou'll never feel you are using an accounting software.")

    it 'should goes in 3 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(0.8)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Backbone of a \nbusiness!")
      expect(@scope.home.banner.subHead).toEqual("Analysis of income-expenses, management of transactions \nand statement of profit-loss is a necessity. \nAnd it's a simple and user-firendly task with Giddh.")

    it 'should goes in 4 in switch case', ->
      @scope.home = {banner: {mainHead: "Hi", subHead: "Hello"}}

      spyOn(Math, "random").andReturn(1)
      @scope.changeText()

      expect(@scope.home.banner.mainHead).toEqual("Accounting is the foundation")
      expect(@scope.home.banner.subHead).toEqual("Accounting is the very first step of every successful business,\nstart using it today! You cannot build the foundation later.")


      