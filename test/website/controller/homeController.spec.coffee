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
    	@scope.home = {banner: {mainHead:"Hi", subHead:"Hello"}}
    	
    	spyOn(Math, "random").andReturn(0.3)
    	@scope.changeText()

    	expect(@scope.home.banner.mainHead).toEqual("Ant or \nElephant")
    	expect(@scope.home.banner.subHead).toEqual("Accounting is a breadth of every Business, small business, Start-ups and even for a person. It makes you alive or at least makes you feel")

    it 'should goes in 2 in switch case', ->
    	@scope.home = {banner: {mainHead:"Hi", subHead:"Hello"}}
    	
    	spyOn(Math, "random").andReturn(0.5)
    	@scope.changeText()

    	expect(@scope.home.banner.mainHead).toEqual("Not for \nAccountants")
    	expect(@scope.home.banner.subHead).toEqual("I am not scary like you imagine accounts. I am simple, basic and very friendly and will never let you regret.")

    it 'should goes in 3 in switch case', ->
    	@scope.home = {banner: {mainHead:"Hi", subHead:"Hello"}}
    	
    	spyOn(Math, "random").andReturn(0.8)
    	@scope.changeText()

    	expect(@scope.home.banner.mainHead).toEqual("Accounting is necessary")
    	expect(@scope.home.banner.subHead).toEqual("Our perception says accounting is the synonyms of necessities, Use any accounting software but use... that’s our motto and that’s why we are.")

    it 'should goes in 4 in switch case', ->
    	@scope.home = {banner: {mainHead:"Hi", subHead:"Hello"}}
    	
    	spyOn(Math, "random").andReturn(1)
    	@scope.changeText()

    	expect(@scope.home.banner.mainHead).toEqual("Accounting is the foundation")
    	expect(@scope.home.banner.subHead).toEqual("Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.")


      