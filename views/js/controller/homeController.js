(function() {
  "use strict";
  var homeController;

  homeController = function($scope, $rootScope, $timeout) {
    $scope.home = {
      "banner": {
        "mainHead": "Accounting is the foundation",
        "subHead": "Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.",
        "p": "Giddh is an online accounting software for everyone",
        "imgSrc": "/views/images/screen.png",
        "imgTitle": "Giddh",
        "banBtnImgSrc": "/views/images/try.png",
        "banBtnImgTitle": "Try Now"
      },
      "middle": {
        "list": [
          {
            "title": "Online on cloud",
            "details": "Access your accounts anywhere and anytime you want,but of course you must be having an Internet.",
            "imgSrc": "/views/images/online_on_cloud.png",
            "imgTitle": "Online on Cloud"
          }, {
            "title": "No need to learn",
            "details": "The biggest advantage of bringing me into use is that you will get familiar with me in less than 10 minutes. If you use me, you can use ANY accounting software.",
            "imgSrc": "/views/images/no_need_to_learn.png",
            "imgTitle": "No need to learn"
          }, {
            "title": "Secure",
            "details": "As long as it is Giddh, you need not worry about data security. Your sensitive data is utmost secure with 256 bit SSL that is FIPS (Federal Information Processing Standard) certified – one of the strongest encryption methods out there. We keep data encrypted, if someone anyhow get the access of database, they will get this @#$@%$%^&^**, although it is impossible.",
            "imgSrc": "/views/images/secure.png",
            "imgTitle": "Secure"
          }, {
            "title": "Multi user",
            "details": "Voila, I allow multi-user access too. Your accounts can be managed by several admins, accountants, and CA’s too…that too in real time. And what’s better is that entries can even be done OFF RECORD",
            "imgSrc": "/views/images/multi_user.png",
            "imgTitle": "Multiple User"
          }, {
            "title": "Recursive Entry",
            "details": "There are some entries that are needed to be made every month. Forget them. I will remember all such recursive entries and alert you the same moment I do those entries",
            "imgSrc": "/views/images/recursive_entry.png",
            "imgTitle": "Recursive Entry"
          }, {
            "title": "Search, Export and API",
            "details": "‘Search’ is the key feature I came to know about when our beta tester explored it. You can download your accounting data in CSV or PDF as per your need and convenience. Also, customization according to your need is possible by my API.",
            "imgSrc": "/views/images/search_export_api.png",
            "imgTitle": "Export"
          }
        ]
      },
      "bottomContent": {
        "text": "These little features, with maximum simplicity makes me ",
        "imgSrc": "/views/images/backlogo.png",
        "altText": "Giddh"
      }
    };
    $scope.changeText = function() {
      var id;
      $timeout($scope.changeText, 5000);
      id = parseInt(Math.random() * 4);
      switch (id) {
        case 0:
          $scope.home.banner.mainHead = 'Analyse BIG \nDATA';
          $scope.home.banner.subHead = 'Accounting is nothing but keeping your transactions in an efficient way. Your eyes could have limitations; let me show you everything in one shot.';
          break;
        case 1:
          $scope.home.banner.mainHead = 'Ant or \nElephant';
          $scope.home.banner.subHead = 'Accounting is a breadth of every Business, small business, Start-ups and even for a person. It makes you alive or at least makes you feel';
          break;
        case 2:
          $scope.home.banner.mainHead = 'Not for \nAccountants';
          $scope.home.banner.subHead = 'I am not scary like you imagine accounts. I am simple, basic and very friendly and will never let you regret.';
          break;
        case 3:
          $scope.home.banner.mainHead = 'Accounting is necessary';
          $scope.home.banner.subHead = 'Our perception says accounting is the synonyms of necessities, Use any accounting software but use... that’s our motto and that’s why we are.';
          break;
        case 4:
          $scope.home.banner.mainHead = 'Accounting is the foundation';
          $scope.home.banner.subHead = 'Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.';
      }
    };
    return $timeout($scope.changeText, 5000);
  };

  angular.module('giddhApp').controller('homeController', homeController);

}).call(this);
