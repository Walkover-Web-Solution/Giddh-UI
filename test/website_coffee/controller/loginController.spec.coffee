'use strict'

describe 'loginController', ->
  beforeEach module("giddhApp")

  beforeEach inject ($rootScope, $controller, loginService) ->
    @scope = $rootScope.$new()
    @loginService = loginService
    @loginController = $controller('loginController',
      {$scope: @scope, loginService: @loginService})

  describe "#hasWhiteSpace", ->
    it "should return true if string contains white space", ->
      s = "Hello I have hite spaces"
      result = @scope.hasWhiteSpace(s)
      expect(result).toBeTruthy()

    it "should return false if string does not contains white space", ->
      s = "HelloNoWhiteSpaces"
      result = @scope.hasWhiteSpace(s)
      expect(result).toBeFalsy()

  describe "#submitUserForm", ->
    it "should call service method if form is valid", ->
      @scope.form.$valid = true
      @scope.user = {"name": "Priyanka Pathak"}
      spyOn(@loginService, "submitUserForm")
      spyOn(@scope, "splitFirstAndLastName")

      @scope.submitUserForm()

      expect(@loginService.submitUserForm).toHaveBeenCalledWith(jasmine.any(Object), @scope.onLoginSuccess,
        @scope.onLoginFailure)
      expect(@scope.splitFirstAndLastName).toHaveBeenCalledWith(@scope.user.name)
      expect(@scope.responseMsg).toBe("loading... Submitting Form")


    it "should not call service method if form is inValid", ->
      @scope.form.$valid = false
      spyOn(@loginService, "submitUserForm")
      spyOn(@scope, "splitFirstAndLastName")

      @scope.submitUserForm()

      expect(@loginService.submitUserForm).not.toHaveBeenCalled()
      expect(@scope.splitFirstAndLastName).not.toHaveBeenCalledWith()

  describe "#splitFirstAndLastName", ->
    it "should split name into first name and last name is name contains white space", ->
      @scope.user = {"name": "Priyanka Pathak"}
      spyOn(@scope, "hasWhiteSpace").andReturn(true)

      @scope.splitFirstAndLastName(@scope.user.name)

      expect(@scope.user.uFname).toBe("Priyanka")
      expect(@scope.user.uLname).toBe("Pathak")

    it "should set blank as last name is name does not contains white space", ->
      @scope.user = {"name": "Priyanka"}
      spyOn(@scope, "hasWhiteSpace").andReturn(false)

      @scope.splitFirstAndLastName(@scope.user.name)

      expect(@scope.user.uFname).toBe("Priyanka")
      expect(@scope.user.uLname).toBe("   ")

  describe "#onLoginSuccess", ->
    it "should set success message if response message is undefined", ->
      @scope.user = {"name": "Priyanka"}
      response = {"message": undefined}

      @scope.onLoginSuccess(response)

      expect(@scope.responseMsg).toBe("Thanks! will get in touch with you soon")

    it "should set response message if not undefined", ->
      @scope.user = {"name": "Priyanka"}
      response = {"message": "Something went wrong"}

      @scope.onLoginSuccess(response)

      expect(@scope.responseMsg).not.toBe("Thanks! will get in touch with you soon")
      expect(@scope.responseMsg).toBe("Something went wrong")