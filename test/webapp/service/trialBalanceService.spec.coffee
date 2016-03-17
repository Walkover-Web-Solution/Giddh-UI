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
      reqParam = {
        companyUniqueName: 'uniqueName'
        fromDate : '04-04-2015'
        toDate: '01-01-2016'
      }
      it 'should call success callback to get trial balance', ->
        @httpBackend.when('GET', '/company/' + reqParam.companyUniqueName + '/trial-balance?fromDate='+ reqParam.fromDate + '&toDate=' + reqParam.toDate).respond(200, {"status": "success"})

        @trialBalService.getAllFor(reqParam).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        @httpBackend.when('GET', '/company/'+ reqParam.companyUniqueName + '/trial-balance?fromDate='+ reqParam.fromDate + '&toDate=' + reqParam.toDate).respond(400, {"status": "error"})

        @trialBalService.getAllFor(reqParam).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
