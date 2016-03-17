'use strict'

describe "Report Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @reportService = $injector.get('reportService')

  describe "#httpRequestMethods", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )

  describe 'historicData',->
    argdata = {
      cUname: ''
      fromDate: ''
      toDate:''
      interval: ''
    }
    data = {}
    it 'should call success callback when historicdata method returns success', ->
      @httpBackend.when('POST', '/company/' + argdata.cUname + '/history').respond(200, {"status": "success"})
      @reportService.historicData(argdata, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

    it 'should call failure callback when historicdata method returns failure', ->
      @httpBackend.when('POST', '/company/' + argdata.cUname + '/history').respond(400, {"status": "error"})
      @reportService.historicData(argdata, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) -> expect(data.status).toBe(400)
        )

  describe 'plGraphData', ->
    argdata = {
      cUname: ''
      fromDate: ''
      toDate:''
      interval: ''
    }
    data = {}
    it 'should call success when plGraphData returns success', ->
      @httpBackend.when('GET', '/company/' + argdata.cUname + '/profit-loss-history').respond(200, {"status": "success"})
      @reportService.plGraphData(argdata).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

    it 'should call failure callback when plGraphData method returns failure', ->
      @httpBackend.when('GET', '/company/' + argdata.cUname + '/profit-loss-history').respond(400, {"status": "error"})
      @reportService.plGraphData(argdata, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) -> expect(data.status).toBe(400)
        )

  describe 'nwGraphData', ->
    argdata = {
      cUname: ''
      fromDate: ''
      toDate:''
      interval: ''
    }
    data = {}
    it 'should call success when nwGraphData returns success', ->
      @httpBackend.when('GET', '/company/' + argdata.cUname + '/networth-history').respond(200, {"status": "success"})
      @reportService.nwGraphData(argdata).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

    it 'should call failure callback when nwGraphData method returns failure', ->
      @httpBackend.when('GET', '/company/' + argdata.cUname + '/networth-history').respond(400, {"status": "error"})
      @reportService.nwGraphData(argdata, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) -> expect(data.status).toBe(400)
        )