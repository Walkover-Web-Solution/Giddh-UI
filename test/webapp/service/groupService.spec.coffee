'use strict'

describe "Group Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @groupService = $injector.get('groupService')
      @accountService = $injector.get('accountService')
      @ledgerService = $injector.get('ledgerService')


  describe "#httpRequestMethods", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )

    describe '#create', ->
      data = {}
      companyUniqueName = 'giddh'
      it 'should call success callback when create group method completes', ->
        @httpBackend.when('POST', '/company/' + companyUniqueName + '/groups').respond(200, {"status": "success"})
        @groupService.create(companyUniqueName, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when create group for company fails', ->
        @httpBackend.when('POST', '/company/' + companyUniqueName + '/groups').respond(400, {"status": "error"})

        @groupService.create(companyUniqueName, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe "#getAllFor", ->
      companyUniqueName = 'giddh'
      it 'should call success callback when get group for company return success', ->
        @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups').respond(200, {"status": "success"})

        @groupService.getAllFor(companyUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback when get group for company fails', ->
        @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups').respond(400, {"status": "error"})

        @groupService.getAllFor(companyUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe "#getAllWithAccountsFor", ->
      companyUniqueName = 'giddh'
      it 'should call success callback when get all group for company return success', ->
        @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups/with-accounts').respond(200, {"status": "success"})

        @groupService.getAllWithAccountsFor(companyUniqueName).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )

      it 'should call failure callback when get all group for company fails', ->
        @httpBackend.when('GET', '/company/' + companyUniqueName + '/groups/with-accounts').respond(400, {"status": "error"})

        @groupService.getAllWithAccountsFor(companyUniqueName).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe "#update", ->
      companyUniqueName = 'giddh'
      group = {oldUName: "name"}
      it 'should call success callback when group updated', ->
        @httpBackend.when('PUT', '/company/' + companyUniqueName + '/groups/'+group.oldUName).respond(200, {"status": "success"})

        @groupService.update(companyUniqueName, group).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group updated', ->
        @httpBackend.when('PUT', '/company/' + companyUniqueName + '/groups/'+group.oldUName).respond(400, {"status": "error"})

        @groupService.update(companyUniqueName, group).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe "#delete", ->
      companyUniqueName = 'giddh'
      group = {uniqueName: "name"}
      it 'should call success callback when group deleted', ->
        @httpBackend.when('DELETE', '/company/' + companyUniqueName + '/groups/'+group.uniqueName).respond(200, {"status": "success"})

        @groupService.delete(companyUniqueName, group).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group deleted', ->
        @httpBackend.when('DELETE', '/company/' + companyUniqueName + '/groups/'+group.uniqueName).respond(400, {"status": "error"})

        @groupService.delete(companyUniqueName, group).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#move', ->
      companyUniqueName = 'giddh'
      data ={}
      unqNamesObj = {compUname: "name", selGrpUname: "name"}
      it 'should call success callback when group moved', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/move').respond(200, {"status": "success"})

        @groupService.move(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group moved', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/move').respond(400, {"status": "error"})

        @groupService.move(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
    describe '#share', ->
      companyUniqueName = 'giddh'
      data ={}
      unqNamesObj = {compUname: "name", selGrpUname: "name"}
      it 'should call success callback when group shared', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/share').respond(200, {"status": "success"})

        @groupService.share(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group shared', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/share').respond(400, {"status": "error"})

        @groupService.share(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
    describe '#unshare', ->
      companyUniqueName = 'giddh'
      data ={}
      unqNamesObj = {compUname: "name", selGrpUname: "name"}
      it 'should call success callback when group unshared', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/unshare').respond(200, {"status": "success"})

        @groupService.unshare(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group unshared', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/unshare').respond(400, {"status": "error"})

        @groupService.unshare(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
    describe '#sharedList', ->
      companyUniqueName = 'giddh'
      data ={}
      unqNamesObj = {compUname: "name", selGrpUname: "name"}
      it 'should call success callback when group sharedList', ->
        @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/shared-with').respond(200, {"status": "success"})

        @groupService.sharedList(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when group sharedList', ->
        @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/shared-with').respond(400, {"status": "error"})

        @groupService.sharedList(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
        
      


  describe "nonHttpRequestMethods", ->
    describe '#flattenGroup', ->
      it 'should take list of group and flatten them', ->
        groupList = [{
          "name": "group1",
          "uniqueName": "g1",
          "groups": [{"name": "group2", "uniqueName": "g2", "groups": []}]
        },
          {"name": "group3", "uniqueName": "g3", "groups": []}]
        result = @groupService.flattenGroup(groupList)
        expect(result).toContain({
          "name": "group2",
          "uniqueName": "g2",
          "groups": [],
          parentGroups: [undefined, {name: 'group1', uniqueName: 'g1'}, {name: 'group2', uniqueName: 'g2'}]
        })

    describe '#flattenGroupsWithAccounts', ->
      it 'should filter out all groups that contains account', ->
        groupList = [{
          "name": "group1",
          "uniqueName": "g1",
          "accounts": [{"name": "a1"}]
        },
          {"name": "group2", "uniqueName": "g2", "accounts": []},
          {"name": "group3", "uniqueName": "g3", "accounts": []}]
        result = @groupService.flattenGroupsWithAccounts(groupList)
        expect(result).toEqual([{"groupName": "group1", "groupUniqueName": "g1", "accountDetails": [{"name": "a1"}]}])

    describe '#flattenAccount', ->
      it 'should take list of groups and flatten them and filter out accounts', ->
        groupList = [{
          "name": "group1",
          "uniqueName": "g1",
          "accounts": [{"name": "a1"}]
          "groups": [{"name": "group2", "uniqueName": "g2", "groups": [], "accounts": []}]
        },
          {"name": "group3", "uniqueName": "g3", "groups": [], "accounts": []}]
        result = @groupService.flattenAccount(groupList)
        expect(result).toContain({"name": "a1", "parentGroups": [{"name": "group1", "uniqueName": "g1"}]})


  describe "#httpRequestMethodsAccountService", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )
    describe '#createAc', ->
      unqNamesObj = {
        compUname: "name"
        selGrpUname: "name"
      }
      data = {}
      it 'should call success callback when account created', ->
        @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(200, {"status": "success"})

        @accountService.createAc(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when account create failed', ->
        @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(400, {"status": "error"})

        @accountService.createAc(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    describe '#updateAc', ->
      unqNamesObj = {
        compUname: "name"
        selGrpUname: "name"
      }
      data = {}
      it 'should call success callback when account updated', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(200, {"status": "success"})

        @accountService.updateAc(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when account update failed', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(400, {"status": "error"})

        @accountService.updateAc(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )
    
    describe '#deleteAc', ->
      unqNamesObj = {
        compUname: "name"
        selGrpUname: "name"
      }
      data = {}
      it 'should call success callback when account deleted', ->
        @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(200, {"status": "success"})

        @accountService.deleteAc(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when account delete failed', ->
        @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts').respond(400, {"status": "error"})

        @accountService.deleteAc(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

  describe "#httpRequestMethods-ledgerService", ->
    afterEach(->
      @httpBackend.flush()
      @httpBackend.verifyNoOutstandingExpectation()
      @httpBackend.verifyNoOutstandingRequest()
    )
    describe '#getLedger', ->
      unqNamesObj = {
        compUname: "cname"
        selGrpUname: "sname"
        acntUname: "aname"
        fromDate: "01-11-2015"
        toDate: "30-11-2015"
      }
      it 'should call success callback after ledger get', ->
        @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(200, {"status": "success"})

        @ledgerService.getLedger(unqNamesObj).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when ledger get failed', ->
        @httpBackend.when('GET', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers?fromDate='+unqNamesObj.fromDate+'&toDate='+unqNamesObj.toDate).respond(400, {"status": "error"})

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
        @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers').respond(200, {"status": "success"})

        @ledgerService.createEntry(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when ledger create failed', ->
        @httpBackend.when('POST', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers').respond(400, {"status": "error"})

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
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(200, {"status": "success"})

        @ledgerService.updateEntry(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when ledger update failed', ->
        @httpBackend.when('PUT', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(400, {"status": "error"})

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
        @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(200, {"status": "success"})

        @ledgerService.deleteEntry(unqNamesObj, data).then(
          (data) -> expect(data.status).toBe("success")
          (data) -> expect(true).toBeFalsy()
        )
      it 'should call failure callback when ledger delete failed', ->
        @httpBackend.when('DELETE', '/company/' + unqNamesObj.compUname + '/groups/'+unqNamesObj.selGrpUname+'/accounts/'+unqNamesObj.acntUname+'/ledgers/'+unqNamesObj.entUname).respond(400, {"status": "error"})

        @ledgerService.deleteEntry(unqNamesObj, data).then(
          (data) -> expect(true).toBeFalsy()
          (data) ->
            expect(data.data.status).toBe("error")
            expect(data.status).toBe(400)
        )

    








