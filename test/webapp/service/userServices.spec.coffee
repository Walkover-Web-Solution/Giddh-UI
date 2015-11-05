'use strict'

describe "User Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @userServices = $injector.get('userServices')


  describe "#httpRequestMethods", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )

    describe '#get user details', ->
      it 'should call success callback to get user detail', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + userUniqueName).respond(200, {"status": "success"})

        @userServices.get(userUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + userUniqueName).respond(400, {"status": "error"})

        @userServices.get(userUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#get auth key for current user', ->
      it 'shpuld call success callback', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/auth-key/' + userUniqueName).respond(200, {"status": "success"})

        @userServices.getKey(userUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/auth-key/' + userUniqueName).respond(400, {"status": "error"})

        @userServices.getKey(userUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#generate new auth key for user', ->
      it 'should call success callback', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('PUT', '/users/' + userUniqueName + '/generate-auth-key').respond(200, {"status": "success"})

        @userServices.generateKey(userUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        userUniqueName = "uniqueName"
        @httpBackend.when('PUT', '/users/' + userUniqueName + '/generate-auth-key').respond(400, {"status": "error"})

        @userServices.generateKey(userUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )