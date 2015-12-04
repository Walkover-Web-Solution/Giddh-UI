'use strict'

describe "Account Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @accountService = $injector.get('accountService')
    @httpBackend.when('GET', '/public/webapp/views/home.html').respond(200)

  afterEach ->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()

  unqNamesObj = {
    compUname: "cName"
    selGrpUname: "gName"
    acntUname: "aName"
  }
  data = {}
  describe '#create', ->
    it 'should call success callback when account created', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts').respond(200,
        {"status": "success"})

      @accountService.createAc(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account create failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts').respond(400,
        {"status": "error"})

      @accountService.createAc(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#update', ->
    it 'should call success callback when account updated', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname).respond(200,
        {"status": "success"})

      @accountService.updateAc(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account update failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname).respond(400,
        {"status": "error"})

      @accountService.updateAc(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#share', ->
    it 'should call success callback when account updated', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname + '/share').respond(200,
        {"status": "success"})

      @accountService.share(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account update failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname + '/share').respond(400,
        {"status": "error"})

      @accountService.share(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#delete', ->
    it 'should call success callback when account deleted', ->
      @httpBackend.when('DELETE',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname).respond(200,
        {"status": "success"})

      @accountService.deleteAc(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account delete failed', ->
      @httpBackend.when('DELETE',
        '/company/' + unqNamesObj.compUname + '/groups/' + unqNamesObj.selGrpUname + '/accounts/' + unqNamesObj.acntUname).respond(400,
        {"status": "error"})

      @accountService.deleteAc(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#move', ->
    data = {
      uniqueName: "name"
    }
    it 'should call success callback when group moved', ->
      @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/move').respond(200, {"status": "success"})

      @accountService.move(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when group moved', ->
      @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/move').respond(400, {"status": "error"})

      @accountService.move(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )