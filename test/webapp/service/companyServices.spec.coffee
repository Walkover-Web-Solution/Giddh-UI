'use strict'

describe 'Company Service', ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @companyServices = $injector.get('companyServices')

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

  describe '#delete company by uniquename', ->
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

  describe '#update company by uniquename', ->
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

  describe '#share by company uniquename', ->
    uniqueName = "uniquename"
    shareRequest = {
      user: "user@example.com"
      role: "admin"
    }
    it 'should call success callback after service called', ->
      @httpBackend.when('PUT', '/company/'+uniqueName+'/share').respond(200, {"status": "success"})
      @companyServices.share(uniqueName, shareRequest).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('PUT', '/company/'+uniqueName+'/share').respond(401, {"status": "error"})
      @companyServices.share(uniqueName, shareRequest).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#shredList by company uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/shared-with').respond(200, {"status": "success"})
      @companyServices.shredList(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/shared-with').respond(401, {"status": "error"})
      @companyServices.shredList(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#unSharedComp company by uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('PUT', '/company/'+uniqueName+'/unshare').respond(200, {"status": "success"})

      @companyServices.unSharedComp(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('PUT', '/company/'+uniqueName+'/unshare').respond(401, {"status": "error"})
      @companyServices.unSharedComp(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
      )

  describe '#getRoles by company uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/shareable-roles').respond(200, {"status": "success"})
      @companyServices.getRoles(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/shareable-roles').respond(401, {"status": "error"})
      @companyServices.getRoles(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#getUploadsList by company uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/imports').respond(200, {"status": "success"})
      @companyServices.getUploadsList(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/imports').respond(401, {"status": "error"})
      @companyServices.getUploadsList(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#getPL by requested params', ->
    reqParam = {
      companyUniqueName: "uniquename"
      # fromDate: "12-10-2013"
      # toDate: "12-10-2014"
    }
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/'+reqParam.companyUniqueName+'/profit-loss').respond(200, {"status": "success"})
      @companyServices.getPL(reqParam).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/'+reqParam.companyUniqueName+'/profit-loss').respond(401, {"status": "error"})
      @companyServices.getPL(reqParam).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )

  describe '#getCompTrans by company uniquename', ->
    uniqueName = "uniquename"
    it 'should call success callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/transactions').respond(200, {"status": "success"})
      @companyServices.getCompTrans(uniqueName).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('GET', '/company/'+uniqueName+'/transactions').respond(401, {"status": "error"})
      @companyServices.getCompTrans(uniqueName).then(
        (data) -> expect(true).toBeFalsy()
        (data) -> expect(data.data.status).toBe("error")
      )


  describe '#updtCompSubs company by uniquename', ->
    data = {
      uniqueName: "uniquename"
    }
    it 'should call success callback after service called', ->
      @httpBackend.when('PUT', '/company/'+data.uniqueName+'/subscription-update').respond(200, {"status": "success"})

      @companyServices.updtCompSubs(data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call error callback after service called', ->
      @httpBackend.when('PUT', '/company/'+data.uniqueName+'/subscription-update').respond(401, {"status": "error"})
      @companyServices.updtCompSubs(data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
      )

	  
