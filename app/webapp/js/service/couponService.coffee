'use strict'

giddh.serviceModule.service 'couponServices', ($resource, $q) ->
  Coupon = $resource('/', 
    {
      'code': @code
    }
    {
      Detail: {
        method: 'GET'
        url: '/coupon/get-coupon'
      }
    }
  )
  couponServices =
    handlePromise: (func) ->
      deferred = $q.defer()
      onSuccess = (data)-> deferred.resolve(data)
      onFailure = (data)-> deferred.reject(data)
      func(onSuccess, onFailure)
      deferred.promise

    couponDetail: (code) ->
      @handlePromise((onSuccess, onFailure) -> Coupon.Detail({
        code: code
      }, onSuccess, onFailure))

  couponServices