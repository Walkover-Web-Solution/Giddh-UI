'use strict'

angular.module('giddhWebApp').service 'homeControllerServices', ($resource) ->
  compResource = $resource('/createCompany', {}, {
    addCmpny: {method: 'POST'}
    # getCmpny: {method: 'GET'},
    # delCmpny: {method: 'DELETE'},
    # updateCmpny: {method: 'UPDATE'}
  })

  compGetResource = $resource('/getCompanyList', {}, {
    getCmpny: {method: 'GET'}
  })

  homeControllerServices =
    createCompany: (cdata, onSuccess, onFailure) ->
      compResource.addCmpny({name: cdata.name, city : cdata.city, uniqueName : cdata.uniqueName}, onSuccess, onFailure)
    getCompList: (onSuccess, onFailure) ->
      compGetResource.getCmpny(onSuccess, onFailure)
        

  homeControllerServices
  
  # example how to set or get
  # getSetCompList: ->
  # compList = []
  # addCompList = (newObj) ->
  #   compList.push newObj

  # getCompList = ->
  #   compList

  # {
  #   addCompList: addCompList
  #   getCompList: getCompList
  # }