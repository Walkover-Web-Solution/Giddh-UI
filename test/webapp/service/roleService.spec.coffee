'use strict'

describe "coupon Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @roleServices = $injector.get('roleServices')

  afterEach ->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()

  describe '#getAll', ->
    it 'should call success callback after get roleServices', ->
      @httpBackend.when('GET', '/roles').respond(200, {"status": "success"})

      @roleServices.getAll().then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when roleServices failed', ->
      @httpBackend.when('GET', '/roles').respond(400, {"status": "error"})

      @roleServices.getAll().then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  

