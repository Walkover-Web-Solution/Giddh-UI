'use strict'

describe "Location Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @locationService = $injector.get('locationService')

  afterEach(->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()
  )

  describe "#searchCountry", ->
    it 'should call success callback when search for country return a promise', ->
      @httpBackend.when('GET', '/location/search?queryString=India').respond(200, {"status": "success"})

      @locationService.searchCountry("India").then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )

    it 'should call error callback when search for country return failure', ->
      @httpBackend.when('GET', '/location/search?queryString=India').respond(401, {"status": "error"})

      @locationService.searchCountry("India").then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe "#searchState", ->
    it 'should call success callback when search for country return a promise', ->
      params = {queryString: "mp", country: "India"}
      @httpBackend.when('GET', '/location/search?country=India&queryString=mp').respond(200, {"status": "success"})

      @locationService.searchState("mp", "India").then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )

    it 'should call error callback when search for country return failure', ->
      @httpBackend.when('GET', '/location/search?country=India&queryString=mp').respond(401, {"status": "error"})

      @locationService.searchState("mp", "India").then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe "#searchCity", ->
    it 'should call success callback when search for city return a promise', ->
      @httpBackend.when('GET', '/location/search?administrator_level=MadhyaPradesh&queryString=Indore').respond(200, {"status": "success"})

      @locationService.searchCity("Indore", "MadhyaPradesh").then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )

    it 'should call error callback when search for city return failure', ->
      @httpBackend.when('GET', '/location/search?administrator_level=MadhyaPradesh&queryString=Indore').respond(401, {"status": "error"})

      @locationService.searchCity("Indore", "MadhyaPradesh").then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )