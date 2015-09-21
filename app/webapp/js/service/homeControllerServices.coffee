'use strict'

angular.module('giddhWebApp').service 'homeControllerServices', ($resource) ->
    createCom = undefined
    homeControllerServices = undefined
    createCom = $resource('/createCompany', {}, sendInvite: method: 'POST')
    homeControllerServices =
      createCompany: (cdata, onSuccess, onFailure) ->
        createCom.sendInvite {
          name: cdata.name
          city: cdata.city
          uniqueName: cdata.uniqueName
        }, onSuccess, onFailure
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

  homeControllerServices