'use strict'

describe "Currency Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @currencyService = $injector.get('currencyService')

  afterEach(->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()
  )

  describe "#getList", ->
    it 'should call success callback when get currency list return successful response', ->
      @httpBackend.when('GET', '/currency').respond(200, {"status": "success"})

      @currencyService.getList(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )

    it 'should call failure callback when get currency list return error as response', ->
      @httpBackend.when('GET', '/currency').respond(401, {"status": "error"})

      @currencyService.getList(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )