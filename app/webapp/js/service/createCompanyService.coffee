'use strict'

angular.module('giddhWebApp').service 'createCompanyService', ($resource) ->
  createCom = $resource('/createCompany', {}, {sendInvite: {method: 'POST'}})

  createCompanyService =
    createCompany: (cdata, onSuccess, onFailure) ->
      createCom.sendInvite({name: cdata.name, city : cdata.city, uniqueName : cdata.uniqueName}, onSuccess, onFailure)
    getSetCompList: ->
        compList = []
        addCompList = (newObj) ->
          compList.push newObj

        getCompList = ->
          compList

        {
          addCompList: addCompList
          getCompList: getCompList
        }  
  createCompanyService