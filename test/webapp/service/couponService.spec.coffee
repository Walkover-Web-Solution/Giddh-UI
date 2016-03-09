'use strict'

describe "coupon Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @couponServices = $injector.get('couponServices')

  afterEach ->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()

  describe '#couponDetail', ->
    code = "abacdfe"
    it 'should call success callback after coupon details', ->
      @httpBackend.when('GET', '/coupon/get-coupon?code='+code).respond(200, {"status": "success"})

      @couponServices.couponDetail(code).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when coupon details failed', ->
      @httpBackend.when('GET', '/coupon/get-coupon?code='+code).respond(400, {"status": "error"})

      @couponServices.couponDetail(code).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  

