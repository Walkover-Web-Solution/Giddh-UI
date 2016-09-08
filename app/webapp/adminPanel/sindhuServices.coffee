'use strict'

giddh.serviceModule.service 'sindhuServices', ($resource, $q) ->
  sindhu = $resource('/sindhu',{})
  sindhuServices