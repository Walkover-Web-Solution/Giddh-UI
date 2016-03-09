'use strict'

describe "Ledger Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @ledgerService = $injector.get('ledgerService')

  afterEach ->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()

  describe '#getLedger', ->
    unqNamesObj = {
      compUname: "cname"
      selGrpUname: "sname"
      acntUname: "aname"
      fromDate: "01-11-2015"
      toDate: "30-11-2015"
    }
    it 'should call success callback after ledger get', ->
      @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(200, {"status": "success"})

      @ledgerService.getLedger(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when ledger get failed', ->
      @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(400, {"status": "error"})

      @ledgerService.getLedger(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#createEntry', ->
    unqNamesObj = {
      compUname: "cname"
      selGrpUname: "sname"
      acntUname: "aname"
    }
    data ={}
    it 'should call success callback after ledger created', ->
      @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers').respond(200, {"status": "success"})

      @ledgerService.createEntry(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when ledger create failed', ->
      @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers').respond(400, {"status": "error"})

      @ledgerService.createEntry(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#updateEntry', ->
    unqNamesObj = {
      compUname: "cname"
      selGrpUname: "sname"
      acntUname: "aname"
      entUname: "ename"
    }
    data ={}
    it 'should call success callback after ledger updated', ->
      @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(200, {"status": "success"})

      @ledgerService.updateEntry(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when ledger update failed', ->
      @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(400, {"status": "error"})

      @ledgerService.updateEntry(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#deleteEntry', ->
    unqNamesObj = {
      compUname: "cname"
      selGrpUname: "sname"
      acntUname: "aname"
      entUname: "ename"
    }
    data ={}
    it 'should call success callback after ledger deleted', ->
      @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(200, {"status": "success"})

      @ledgerService.deleteEntry(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when ledger delete failed', ->
      @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(400, {"status": "error"})

      @ledgerService.deleteEntry(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#getOtherTransactions', ->
    unqNamesObj = {
      compUname: "cname"
      acntUname: "aname"
    }
    it 'should call success callback after ledger get', ->
      @httpBackend.when('GET', '/yodlee/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/transactions').respond(200, {"status": "success"})

      @ledgerService.getOtherTransactions(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when ledger get failed', ->
      @httpBackend.when('GET', '/yodlee/company/' + unqNamesObj.compUname + '/accounts/'+unqNamesObj.acntUname+'/transactions').respond(400, {"status": "error"})

      @ledgerService.getOtherTransactions(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

