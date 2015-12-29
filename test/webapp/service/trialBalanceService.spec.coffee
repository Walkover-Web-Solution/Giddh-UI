'use strict'

describe 'Trial Balance Service', ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @trialBalService = $injector.get('trialBalService')

  describe "#httpRequestMethods", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )

    describe '#get trial balance', ->
      xit 'should call success callback to get trial balance', ->
        companyUniqueName = "companyUniqueName"
        @httpBackend.when('GET', '/company/:'+companyUniqueName+'/trial-balance').respond(200, {"status": "success"})

        @trialBalService.getAllFor(companyUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      xit 'should call failure callback', ->
        companyUniqueName = "companyUniqueName"
        @httpBackend.when('GET', '/company/:'+companyUniqueName+'/trial-balance').respond(400, {"status": "error"})

        @trialBalService.getAllFor(companyUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
