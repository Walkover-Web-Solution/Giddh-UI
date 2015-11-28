'use strict'

describe 'Company Service', ->
  beforeEach module ("giddhWebApp")
  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @companyServices = $injector.get('companyServices')
    @httpBackend.when('GET', '/public/webapp/views/home.html').respond(200)

  afterEach(->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()
  )

  describe '#create  create new Company', ->
    it 'should call success callback after make new company', ->
      @httpBackend.when('POST', '/company').respond(200, {"status": "success"})

      cdata = {"name": "Somename", "city": "Indore"}

      @companyServices.create(cdata).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeTruthy()
      )

    it 'should call error callback after new company failed', ->
      @httpBackend.when('POST', '/company').respond(401, {"status": "error"})
      cdata = {"name": "Somename", "city": "Indore"}
      @companyServices.create(cdata).then(
        (data) -> expect(false).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#getAll Get all company List', ->
    it 'should call success callback after company list service called', ->
      @httpBackend.when('GET', '/company/all').respond(200, {"status": "success"})
      @companyServices.getAll().then(
        (data) -> expect(data.status).toBe("success")
      )
    it 'should call error callback after company list service called', ->
      @httpBackend.when('GET', '/company/all').respond(401, {"status": "error"})
      @companyServices.getAll().then(
        (data) -> expect(false).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#get Get Company details by uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/' + uniqueName).respond(200, {"status": "success"})
      @companyServices.get(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/' + uniqueName).respond(401, {"status": "error"})
      @companyServices.get(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#delete delete company by uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('DELETE', '/company/' + uniqueName).respond(200, {"status": "success"})
      @companyServices.delete(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('DELETE', '/company/' + uniqueName).respond(401, {"status": "error"})
      @companyServices.delete(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )


  describe '#update  company by uniquename', ->
    updtData = {
      uniqueName: "uniquename"
    }
    it 'should call success callback after service called', ->
      @httpBackend.when('PUT', '/company/' + updtData.uniqueName).respond(200, {"status": "success"})

      @companyServices.update(updtData).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('PUT', '/company/' + updtData.uniqueName).respond(401, {"status": "error"})
      @companyServices.update(updtData).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
      )

	  
