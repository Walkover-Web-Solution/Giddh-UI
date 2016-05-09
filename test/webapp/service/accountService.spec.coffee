'use strict'

describe "Account Service", ->
  beforeEach module("serviceModule")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @accountService = $injector.get('accountService')

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
  describe '#createAc', ->
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

  describe '#updateAc', ->
    it 'should call success callback when account updated', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(200,
        {"status": "success"})

      @accountService.updateAc(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account update failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(400,
        {"status": "error"})

      @accountService.updateAc(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#deleteAc', ->
    it 'should call success callback when account deleted', ->
      @httpBackend.when('DELETE',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(200,
        {"status": "success"})

      @accountService.deleteAc(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account delete failed', ->
      @httpBackend.when('DELETE',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(400,
        {"status": "error"})

      @accountService.deleteAc(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#get', ->
    it 'should call success callback when get account', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(200,
        {"status": "success"})

      @accountService.get(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account get failed', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname).respond(400,
        {"status": "error"})

      @accountService.get(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#share', ->
    it 'should call success callback when account shared', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/share').respond(200,
        {"status": "success"})

      @accountService.share(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account sharing failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/share').respond(400,
        {"status": "error"})

      @accountService.share(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#unshare', ->
    it 'should call success callback when account unsared', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/unshare').respond(200,
        {"status": "success"})

      @accountService.unshare(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account unsaring failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/unshare').respond(400,
        {"status": "error"})

      @accountService.unshare(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#sharedWith', ->
    it 'should call success callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/shared-with').respond(200,
        {"status": "success"})

      @accountService.sharedWith(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/shared-with').respond(400,
        {"status": "error"})

      @accountService.sharedWith(unqNamesObj).then(
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
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/move').respond(200,
        {"status": "success"})

      @accountService.move(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when group moved', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/move').respond(400,
        {"status": "error"})

      @accountService.move(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#exportLedger', ->
    it 'should call success callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/export-ledger').respond(200,
        {"status": "success"})

      @accountService.exportLedger(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/export-ledger').respond(400,
        {"status": "error"})

      @accountService.exportLedger(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#ledgerImportList', ->
    it 'should call success callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/xls-imports').respond(200,
        {"status": "success"})

      @accountService.ledgerImportList(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/xls-imports').respond(400,
        {"status": "error"})

      @accountService.ledgerImportList(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#merge', ->
    it 'should call success callback when account unsared', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/merge').respond(200,
        {"status": "success"})

      @accountService.merge(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account unsaring failed', ->
      @httpBackend.when('PUT',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/merge').respond(400,
        {"status": "error"})

      @accountService.merge(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#unMergeDelete', ->
    it 'should call success callback when account unsared', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/un-merge').respond(200,
        {"status": "success"})

      @accountService.unMergeDelete(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account unsaring failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/un-merge').respond(400,
        {"status": "error"})

      @accountService.unMergeDelete(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  # describe '#unMerge', ->
  #   xit 'should call success callback when account unshared', ->
  #     @httpBackend.when('POST',
  #       '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/un-merge').respond(200,
  #       {"status": "success"})

  #     @accountService.unMerge(unqNamesObj, data).then(
  #       (data) -> expect(data.status).toBe("success")
  #       (data) -> expect(true).toBeFalsy()
  #     )
  #   xit 'should call failure callback when account unsharing failed', ->
  #     @httpBackend.when('POST',
  #       '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/un-merge').respond(400,
  #       {"status": "error"})

  #     @accountService.unMerge(unqNamesObj, data).then(
  #       (data) -> expect(true).toBeFalsy()
  #       (data) ->
  #         expect(data.data.status).toBe("error")
  #         expect(data.status).toBe(400)
  #     )
  
  describe '#emailLedger', ->
    it 'should call success callback when account unshared', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/ledgers/mail').respond(200,
        {"status": "success"})

      @accountService.emailLedger(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account unsharing failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/ledgers/mail').respond(400,
        {"status": "error"})

      @accountService.emailLedger(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#getInvList', ->
    it 'should call success callback when getInvList success', ->
      unqNamesObj.fromDate = "01-01-2016"
      unqNamesObj.toDate = "30-04-2016"
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(200,
        {"status": "success"})

      @accountService.getInvList(unqNamesObj).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when getInvList failed', ->
      unqNamesObj.fromDate = "01-01-2016"
      unqNamesObj.toDate = "30-04-2016"
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(400,
        {"status": "error"})

      @accountService.getInvList(unqNamesObj).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#prevInvoice', ->
    it 'should call success callback when prevInvoice success', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/preview').respond(200,
        {"status": "success"})

      @accountService.prevInvoice(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account prevInvoice failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/preview').respond(400,
        {"status": "error"})

      @accountService.prevInvoice(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#genInvoice', ->
    it 'should call success callback when genInvoice success', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/generate').respond(200,
        {"status": "success"})

      @accountService.genInvoice(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account genInvoice failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/generate').respond(400,
        {"status": "error"})

      @accountService.genInvoice(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#downloadInvoice', ->
    it 'should call success callback when downloadInvoice success', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/download').respond(200,
        {"status": "success"})

      @accountService.downloadInvoice(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when account downloadInvoice failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/download').respond(400,
        {"status": "error"})

      @accountService.downloadInvoice(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#prevOfGenInvoice', ->
    it 'should call success callback when prevOfGenInvoice success', ->
      unqNamesObj.invoiceUniqueID = "1234"
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/'+unqNamesObj.invoiceUniqueID+'/preview').respond(200,
        {"status": "success"})

      @accountService.prevOfGenInvoice(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when prevOfGenInvoice failed', ->
      @httpBackend.when('GET',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/'+unqNamesObj.invoiceUniqueID+'/preview').respond(400,
        {"status": "error"})

      @accountService.prevOfGenInvoice(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )

  describe '#mailInvoice', ->
    it 'should call success callback when mailInvoice success', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/mail').respond(200,
        {"status": "success"})

      @accountService.mailInvoice(unqNamesObj, data).then(
        (data) -> expect(data.status).toBe("success")
        (data) -> expect(true).toBeFalsy()
      )
    it 'should call failure callback when mailInvoice failed', ->
      @httpBackend.when('POST',
        '/company/' + unqNamesObj.compUname + '/accounts/' + unqNamesObj.acntUname + '/invoices/mail').respond(400,
        {"status": "error"})

      @accountService.mailInvoice(unqNamesObj, data).then(
        (data) -> expect(true).toBeFalsy()
        (data) ->
          expect(data.data.status).toBe("error")
          expect(data.status).toBe(400)
      )





  