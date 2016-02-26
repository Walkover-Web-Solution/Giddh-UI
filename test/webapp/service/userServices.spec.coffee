'use strict'

describe "User Service", ->
  beforeEach module("serviceModule")

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
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName).respond(200, {"status": "success"})

        @userServices.get(uniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName).respond(400, {"status": "error"})

        @userServices.get(uniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#get auth key for current user', ->
      it 'shpuld call success callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/auth-key/' + uniqueName).respond(200, {"status": "success"})

        @userServices.getKey(uniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/auth-key/' + uniqueName).respond(400, {"status": "error"})

        @userServices.getKey(uniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#generate new auth key for user', ->
      it 'should call success callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('PUT', '/users/' + uniqueName + '/generate-auth-key').respond(200, {"status": "success"})

        @userServices.generateKey(uniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('PUT', '/users/' + uniqueName + '/generate-auth-key').respond(400, {"status": "error"})

        @userServices.generateKey(uniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#get subscription list', ->
      it 'shpuld call success callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName+'/subscribed-companies').respond(200, {"status": "success"})

        @userServices.getsublist(uniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName+'/subscribed-companies').respond(400, {"status": "error"})

        @userServices.getsublist(uniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#get user subscription list', ->
      obj = {
        name: "uniqueName"
        num: 1
      }
      it 'shpuld call success callback', ->
        @httpBackend.when('GET', '/users/' + obj.name+'/transactions?page='+obj.num).respond(200, {"status": "success"})

        @userServices.getUserSublist(obj).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        @httpBackend.when('GET', '/users/' + obj.name+'/transactions?page='+obj.num).respond(400, {"status": "error"})

        @userServices.getUserSublist(obj).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#get user wallet balance', ->
      it 'shpuld call success callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName+'/available-credit').respond(200, {"status": "success"})

        @userServices.getWltBal(uniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback', ->
        uniqueName = "uniqueName"
        @httpBackend.when('GET', '/users/' + uniqueName+'/available-credit').respond(400, {"status": "error"})

        @userServices.getWltBal(uniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )



