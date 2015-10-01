'use strict'

describe "Group Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @groupService = $injector.get('groupService')

  afterEach(->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()
  )

  describe "#getAllFor", ->
    it 'should call success callback when get group for company return success', ->
      companyUniqueName = 'walkover123'
      @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups').respond(200, {"status": "success"})

      @groupService.getAllFor(companyUniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )

    it 'should call failure callback when get group for company fails', ->
      companyUniqueName = 'walkover123'
      @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups').respond(400, {"status": "error"})

      @groupService.getAllFor(companyUniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )