'use strict'

describe "Login Service", ->
  beforeEach module("giddhApp")

  beforeEach ->
    inject ($injector) ->
      @httpBackend = $injector.get('$httpBackend')
      @loginService = $injector.get('loginService')

  afterEach(->
    @httpBackend.flush()
    @httpBackend.verifyNoOutstandingExpectation()
    @httpBackend.verifyNoOutstandingRequest()
  )

  describe "#submitUserForm", ->
    it 'should submit user form', ->
      user = {uFname: "Priyanka", uLname: "pathak", email: "p@p.com", company: "Walkover", reason: "blank"}
      @httpBackend.when('POST', '/contact/submitDetails', user).respond(200,
        {"message": "success"})

      @loginService.submitUserForm(user,
        (data)-> expect(data.message).toBe('success'),
        (data)-> expect(true).toBeFalsy())

    it 'should not submit user form', ->
      user = {uFname: "Priyanka", uLname: "pathak", email: "p@p.com", company: "Walkover", reason: "blank"}
      @httpBackend.when('POST', '/contact/submitDetails', user).respond(401,
        {"message": "failure message"})

      @loginService.submitUserForm(user,
        (data)-> expect(true).toBeFalsy()
        (data)-> expect(data.data.message).toBe("failure message"))