"use strict"
pricingController = ($scope) ->
  $scope.pricing =
    "banner":
      "mainHead": "Free",
      "mainHead1": "",
      "subHead": "Pure unlimited accounting. All for free. No hidden fees!",
      "banBtnImgSrc": "/public/website/images/try.png",
      "banBtnImgTitle": "Try Now"
    "middle":
      "list": [
        {
          "title": "Unlimited companies",
          "details": "Create unlimited Companies in your account and do as many entries associated with the Companies. Giddh can handle multiple transactions of multiple Companies with extreme ease."
        },
        {
          "title": "Free of cost",
          "details": "Giddh's beta version comes free of cost with no hidden charges associated. Create multi-users and hold as many records. If you are on Giddh, it's free!"
        },
        {
          "title": "Round the clock support",
          "details": "Our team works hard so that we can make your accounting life easy. Give us a call or write to us whenever you face any trouble. Our team is available 24*7."
        }
      ]

angular.module('giddhApp').controller 'pricingController', pricingController