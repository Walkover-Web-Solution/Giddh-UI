'use strict'

describe 'ledgerController', ->
  beforeEach module('giddhWebApp')

  beforeEach inject ($rootScope, $controller, localStorageService, toastr, groupService, $q, $modal) ->
    @scope = $rootScope.$new()
    @rootScope = $rootScope
    @localStorageService = localStorageService
    @toastr = toastr
    @modal = $modal
    @q = $q
    @ledgerController = $controller('ledgerController',
        {
          $scope: @scope,
          $rootScope: @rootScope,
          localStorageService: @localStorageService
        })

  describe '#checklocalstorageforselectedcompany', ->
    it 'should get key from localStorageService', ->
      obj = {name: "walkover"}
      spyOn(@localStorageService, 'keys').andReturn(["_selectedCompany"])
      spyOn(@localStorageService, 'get').andReturn(obj)
      # expect(@scope.selectedCompany).toEqual(obj)

      # expect(@scope.dateOptions).toEqual({
      #   'year-format': "'yy'",
      #   'starting-day': 1,
      #   'showWeeks': false,
      #   'show-button-bar': false,
      #   'year-range': 1,
      #   'todayBtn': false
      # })


      
    
      

    