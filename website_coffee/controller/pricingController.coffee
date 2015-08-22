"use strict"
pricingController = ($scope, $rootScope, $timeout) ->
	$scope.pricing = 
        "banner": 
            "mainHead":"$100",
            "mainHead1":"A year/user",
            "subHead":"No accounting on this. Let’s make one plan, one pricing and no complications.",
            "banBtnImgSrc":"/views/images/try.png",
            "banBtnImgTitle":"Try Now"
        "middle":
            "list":[
                {
                    "title" : "Unlimited companies",
                    "details" : "Our plan has no limitation, as we said it is only one plan and all is yours. Everything is unlimited including unlimited companies."
                },
                {
                    "title" : "Charges are per user",
                    "details" : "You can add as many user you want and then it is free for those users to add unlimited companies in their account. We charge only per user (email id) basis, If it is added once then all features are free."
                },
                {
                    "title" : "24X7 email support",
                    "details" : "Business never stops whether it is midnight of new year. My support guys are trained and love to assist you anytime you need it."
                }
            ]

angular.module('giddhApp').controller 'pricingController', pricingController