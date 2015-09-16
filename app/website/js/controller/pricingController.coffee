"use strict"
pricingController = ($scope) ->
  $scope.pricing =
    "banner":
      "mainHead": "Free",
      "mainHead1": "",
      "subHead": "No accounting on this. Let’s make one plan, No pricing and no complications.",
      "banBtnImgSrc": "/public/website/images/try.png",
      "banBtnImgTitle": "Try Now"
    "middle":
      "list": [
        {
          "title": "Unlimited companies",
          "details": "Our plan has no limitation, as we said it is only one plan and all is yours. Everything is unlimited including unlimited companies."
        },
        {
          "title": "Charges are per user",
          "details": "Add as many user you want. It is free for these users to add
unlimited companies in their account. We charge only per user 
(email ID) basis with all features free for them."
        },
        {
          "title": "24X7 email support",
          "details": "Business never stops whether it is midnight of new year. My support guys are trained and love to assist you anytime you need it."
        }
      ]

angular.module('giddhApp').controller 'pricingController', pricingController