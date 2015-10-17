'use strict'

describe "Group Service", ->
  beforeEach module("giddhWebApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @groupService = $injector.get('groupService')


  describe "#httpRequestMethods", ->
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
        expect(result).toContain({"name": "group2", "uniqueName": "g2", "groups": []})

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
        expect(result).toContain({"name": "a1", "pName": ["group1"], "pUnqName": ["g1"]})

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