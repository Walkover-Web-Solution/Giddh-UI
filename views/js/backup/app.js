var app = angular.module("giddhApp", [
  'satellizer'
]);

app.config(function($authProvider) {
  $authProvider.google({
    clientId: '40342793-h9vu599ed13f54kb673t2ltbc713vad7.apps.googleusercontent.com'
  });
});
app.run(function($rootScope, $http) {
  console.log("app init");
  $rootScope.pagesData;
});

app.controller('homeController', ['$scope',"$rootScope","$timeout",function ($scope, $rootScope,$timeout) 
{
    $scope.home = {
        "banner": {
            "mainHead":"Accounting is the foundation",            
            "subHead":"Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.",
            "p": "<span>Giddh</span> is an online accounting software for everyone",
            "imgSrc": "/views/images/screen.png",
            "imgTitle" : "Giddh",
            "banBtnImgSrc":"/views/images/try.png",
            "banBtnImgTitle":"Try Now"
        },
        "middle": {
            "list":[
                {
                    "title" : "Online on cloud",
                    "details" : "Access your accounts anywhere and anytime you want,but of course you must be having an Internet.",
                    "imgSrc": "/views/images/online_on_cloud.png",
                    "imgTitle" : "Online on Cloud"
                },
                {
                    "title" : "No need to learn",
                    "details" : "The biggest advantage of bringing me into use is that you will get familiar with me in less than 10 minutes. If you use me, you can use ANY accounting software.",
                    "imgSrc": "/views/images/no_need_to_learn.png",
                    "imgTitle" : "No need to learn"
                },
                {
                    "title" : "Secure",
                    "details" : "As long as it is Giddh, you need not worry about data security. Your sensitive data is utmost secure with 256 bit SSL that is FIPS (Federal Information Processing Standard) certified – one of the strongest encryption methods out there. We keep data encrypted, if someone anyhow get the access of database, they will get this @#$@%$%^&^**, although it is impossible.",
                    "imgSrc": "/views/images/secure.png",
                    "imgTitle" : "Secure"
                },
                {
                    "title" : "Multi user",
                    "details" : "Voila, I allow multi-user access too. Your accounts can be managed by several admins, accountants, and CA’s too…that too in real time. And what’s better is that entries can even be done OFF RECORD",
                    "imgSrc": "/views/images/multi_user.png",
                    "imgTitle" : "Multiple User"
                },
                {
                    "title" : "Recursive Entry",
                    "details" : "There are some entries that are needed to be made every month. Forget them. I will remember all such recursive entries and alert you the same moment I do those entries",
                    "imgSrc": "/views/images/recursive_entry.png",
                    "imgTitle" : "Recursive Entry"
                },
                {
                    "title" : "Search, Export and API",
                    "details" : "‘Search’ is the key feature I came to know about when our beta tester explored it. You can download your accounting data in CSV or PDF as per your need and convenience. Also, customization according to your need is possible by my API.",
                    "imgSrc": "/views/images/search_export_api.png",
                    "imgTitle" : "Export"
                }
            ]
        },
        "bottomContent":{
            "text": "These little features, with maximum simplicity makes me ",
            "imgSrc": "/views/images/backlogo.png",
            "altText" :"Giddh"
        }
    }

    // slide banner 
    var changeText = function() {
        $timeout(changeText, 5000);
        var id = parseInt(Math.random()*4)
        var heading = angular.element( document.querySelector( '#imd' ));
        var subHeading = angular.element( document.querySelector( '#imdContent' ));
        switch(id){
            case 0:
            heading.html('Analyse BIG<br/> DATA');
            subHeading.html('Accounting is nothing but keeping your transactions in an efficient way. Your eyes could have limitations; let me show you everything in one shot.');
            break;
            case 1:
            heading.html("Ant or<br/> Elephant"); 
            subHeading.html('Accounting is a breadth of every Business, small business, Start-ups and even for a person. It makes you alive or at least makes you feel');
            break;
            case 2:
            heading.html('Not for<br/> Accountants');   
            subHeading.html('I am not scary like you imagine accounts. I am simple, basic and very friendly and will never let you regret.');
            break;
            case 3:
            heading.html("Accounting is necessary"); 
            subHeading.html("Our perception says accounting is the synonyms of necessities, Use any accounting software but use... that’s our motto and that’s why we are.");
            break;
            case 4:
            heading.html("Accounting is the foundation"); 
            subHeading.html('Accounting is the very first step of every successful business, Start using it today! You cannot build the foundation later.');
            break;
        }
    }
    $timeout(changeText, 5000);
}]);
    
/*Pricing page*/
app.controller("pricingController", ["$scope","$rootScope", function ($scope, $rootScope){
    $scope.pricing = {
        "banner": {
            "mainHead":"$100",
            "mainHead1":"A year/user",
            "subHead":"No accounting on this. Let’s make one plan, one pricing and no complications.",
            "banBtnImgSrc":"/views/images/try.png",
            "banBtnImgTitle":"Try Now"
        },
        "middle": {
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
        }
    }
}]);


/*login page*/
app.controller("loginController", ["$scope", "$rootScope", "$http", "$timeout", "$auth", function($scope, $rootScope, $http, $timeout, $auth ){

    /*webpage data*/
    $scope.login = {
        "banner": {
            "mainHead":"Welcome to the world of",
            "mainHead1":"secure and online accounting"
        },
        "middle": {
        }
    }

    var rand = Math.random() * 4;
    window.onload = function () {
        alertMsg(parseInt(rand));
    }
    var alertMsg = function() {
        $timeout(alertMsg, 5000);
        var id = parseInt(Math.random()*3);
        var ele = angular.element( document.querySelector( '#tipscnt' ));
        switch (id) {
            case 0:
                ele.html('Tip : "Every transaction has a statement."');
                break;
            case 1:
                ele.html('Tip : "Your account book will never contain your name."');
                break;
            case 2:
                ele.html('Tip : "Every statement will have an entry."');
                break;
            case 3:
                ele.html('Tip : "Ateast two things will happen in every statement."');
                break;
            case 3:
                ele.html('Tip : "Accounting works on double entry system"');
                break;
        }
    }
    $timeout(alertMsg, 5000);

    $scope.loginWithGoogle=function() {
    };

    $scope.authenticate = function(provider) {
        $auth.authenticate(provider).then(function(response) {
            console.log(response, 'You have successfully created a new account');
        })
        .catch(function(response) {
          console.log(response);
        });
    }
    
}]);

/*version page*/
app.controller("versionController", ["$scope", "$rootScope", "$http", "$timeout", function($scope, $rootScope, $http, $timeout){
    $scope.version = {
        "banner": {
            "mainHead":"Giddh",
            "mainHead1":"VERSION 2",
            "subHead":"Features are never ending but important thing is that we bring the most important feature for you with the same simplicity. Here are few most exciting features coming in Giddh version 2.",
            "banBtnImgSrc":"/views/images/try.png",
            "banBtnImgTitle":"Try Now"
        },
        "middle": {
            "list":[
                {
                    "title" : "Share",
                    "details" : "Not only company, you can share an individual account too. This will give you and your party better clarity and accountability to understand the accounts."
                },
                {
                    "title" : "Grouping of companies",
                    "details" : "You may call it branch or your department, What if you want to analyse your product separately and at the same time, bring them together to see as big picture? This could be the only way or the best way."
                },
                {
                    "title" : "Chrome and Android App",
                    "details" : "Internet is fantastic, but what if you can’t get access to it when you need to make an entry. Chrome and Android App has sync facility so that your transactions will never be missed and it will be in real time always."
                }
            ]
        }
    };
}]);

/*Contact page*/
app.controller("contactController", ["$scope", "$rootScope", "$http", "$timeout", function($scope, $rootScope, $http, $timeout){
    $scope.contact = {
        "banner": {
            "mainHead":"support",
            "mainHead1":"@giddh.com",
            "subHead":"I would love to read you. I have some guys who are reading your emails day and night for the support, feature request, press or sales.",
            "banBtnImgSrc":"/views/images/try.png",
            "banBtnImgTitle":"Try Now"
        },
        "middle": {
            "formHead":"You can email me",
            "title":"Get In Touch",
            "socialTitle" : "Connect with us:",
            "socialList" : [
                {
                    "name": "Google",
                    "url": "javascript:void(0)",
                    "class": "gplus"
                },
                {
                    "name": "Facebook",
                    "url": "http://www.facebook.com/giddh",
                    "class": "fb"
                },
                {
                    "name": "Linkedin",
                    "url": "javascript:void(0)",
                    "class": "in"
                },
                {
                    "name": "Twitter",
                    "url": "https://twitter.com/giddhcom/",
                    "class": "twit"
                },
                {
                    "name": "Youtube",
                    "url": "http://www.youtube.com/watch?v=p6HClX7mMMY",
                    "class": "yt"
                },
                {
                    "name": "RSS",
                    "url": "http://blog.giddh.com/feed/",
                    "class": "rss"
                }
            ]
        }
    };
    $scope.form = {};
    $scope.integerval = /^\d*$/;
    // function to submit the form after all validation has occurred            
    $scope.submitForm = function() {

        // check to make sure the form is completely valid
        if ($scope.form.$valid) {
            console.log($scope.form);
            var htmlBody = '<div>Name: ' + $scope.form.uEmail.$viewValue + '</div>' +
            '<div>Email: ' + $scope.form.uNumber.$viewValue + '</div>' +
             '<div>Email: ' + $scope.form.uEmail.$viewValue + '</div>' +
             '<div>Message: ' + $scope.form.uMessage.$viewValue + '</div>' +
             '<div>Date: ' + (new Date()).toString() + '</div>';

            console.log('our form is amazing', htmlBody);
            
            $http({
              url: 'https://api.postmarkapp.com/email',
              method: 'POST',
              data: {
                'From': 'foo@foo.com',
                'To': 'bar@bar.com',
                'HtmlBody': htmlBody,
                'Subject': 'New Contact Form Submission'
              },
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-Postmark-Server-Token': '8569dcd45-6a1a-4e7b-ae75-ea37629de4'
              }
            }).
            success(function (data) {
                $scope.success = true;
                $scope.user = {};
            }).
            error(function (data) {
                $scope.error = true;
            });
        }

    };
}]);

/*invoice page*/
app.controller('invoiceController', ['$scope',function ($scope){
     $scope.invoice = {
        "middle": {
            "list":[
                {
                    "title" : "Invoice",
                    "details" : "The business world rests upon transactions such as buying and selling every day in and day out. Invoice is a small formal document issued by the seller to the buyer which holds all the important information of the purchase regarding the quantity, price, discount, time of billing, taxes and due date, etc. literal meaning of invoice is to own or being owed. Most common forms of invoices today are Electronic invoices.",
                    "imgSrc": "/views/images/online_on_cloud.png",
                    "imgTitle" : "Online on Cloud"
                },
                {
                    "title" : "For small fishes",
                    "details" : "It is a blessing! In a small group of motivated people for who sky is the limit. Don’t have all the time to prepare invoices. Entrepreneurs can focus on business expansion rather than getting involved in accounts management which can be done by software alone. It saves hell lot of time along with the cost of labor. One thing you can be sure of in your organization will be invoicing with Giddh.",
                    "imgSrc": "/views/images/no_need_to_learn.png",
                    "imgTitle" : "No need to learn"
                },
                {
                    "title" : "The software",
                    "details" : "Invoice software is the latest fad in the industry! It is said to be great for small businesses and freelancers. As you can manage multiple accounts/customers simultaneously this ultimately leads to raised profits. This is the best means of managing invoices most efficiently and cost effectively. Enterprises that have less manpower and more work power benefit the best out of it. Giddh users have access to its invoicing service also for free. ",
                    "imgSrc": "/views/images/secure.png",
                    "imgTitle" : "Secure"
                },
                {
                    "title" : "Technically",
                    "details" : "Invoicing software has filled the time gaps! It is many folds faster in receiving payments online as compared to paper based invoicing ways. Creating invoices appeared to be quite tricky and on top of it were very time consuming. Using invoicing software is easy and faster to create and send professional looking invoices which are difficult to create otherwise. Invoicing software has increased the convenience and comfort hugely.",
                    "imgSrc": "/views/images/multi_user.png",
                    "imgTitle" : "Multiple User"
                },
                {
                    "title" : "Online invoice creator",
                    "details" : "In this cut throat competitive market it is utmost important to keep up with the technology for slightest advancement in the industry. How can one lag in the accounts department, which is considered as the back bone of any business. Online invoice creator was formed in order to reduce the distance and time taken in delivery and payment receiving. Online invoice creator is now facilitated with the PDF converter as well.",
                    "imgSrc": "/views/images/recursive_entry.png",
                    "imgTitle" : "Recursive Entry"
                },
                {
                    "title" : "Easy",
                    "details" : "Customers are the first priority for any business enterprise and using simple invoice software you top the list in customer care.  From production techniques to the packaging industry every sector of the business is growing at jet speed. You need to revamp you invoicing as well and with the new online invoice software you stay at par with the competitors. Online invoicing is more creative and advanced way of interacting with the customers.",
                    "imgSrc": "/views/images/search_export_api.png",
                    "imgTitle" : "Export"
                }
            ]
        }
     };
}]);

/*billing page*/
app.controller('billingController', ['$scope',function ($scope){
     $scope.billing = {
        "middle": {
            "list":[
                {
                    "title" : "Yearn profits?",
                    "details" : "Your customer should get a bill for every purchase! If you are dissipating goods for free then it’s all together a different thing. But an apt billing system justifies your hard work in the form of correct bills. As if bills are computed correctly only then you get justified profits and that is all what you work hard for. Now with the new and easy billing software you get what you deserve.",
                    "imgSrc": "/views/images/online_on_cloud.png",
                    "imgTitle" : "Online on Cloud"
                },
                {
                    "title" : "Online billing ",
                    "details" : "Technology again! Speed and time are the two factors which always fall short. The concept of online billing targets both of them equally. It saves time in the entire billing process and is the fastest way of billing in the industry. It frees half of the billing crew to do some other jobs while it finishes off half the task alone. This way it reduces the physical efforts as well!",
                    "imgSrc": "/views/images/no_need_to_learn.png",
                    "imgTitle" : "No need to learn"
                },
                {
                    "title" : "Err not! ",
                    "details" : "Billing system software takes away the strain off your grey matter by performing major tasks on its own. It is a computer designed program which automatically computes the bill according to the utility and usage. Billing software solution is great as it is very accurate and designed to perform zero errors which can be expected when computed by humans as to err is human but we are not gods to forgive such mistakes!",
                    "imgSrc": "/views/images/secure.png",
                    "imgTitle" : "Secure"
                },
                {
                    "title" : "The awaited ",
                    "details" : "Bill software is what you have been looking for since long! It has reduced the headaches of many business personals and so will yours. Your wish of hassle free billing system is in action with the new software which is fully automated and works as per your terms and conditions. The technicians just have to fill in the standards like the price per quantity and et al, which is later computed by the software.",
                    "imgSrc": "/views/images/multi_user.png",
                    "imgTitle" : "Multiple User"
                },
                {
                    "title" : "Pay anytime ",
                    "details" : "A billing or invoicing software is the paper less way of computing and sending out bills. It is easier both for the customers as well as the business personnel. The customers can access the bill anytime and anywhere widening the scope for bill payment faster and easier. It has a good design with a good level of security. One has various options to secure his/her transactions on choice.",
                    "imgSrc": "/views/images/recursive_entry.png",
                    "imgTitle" : "Recursive Entry"
                },
                {
                    "title" : "Sigh of relief ",
                    "details" : "Customer relations in small businesses are of utmost importance. At such times when you have a billing software doing the most annoying thing for your customers, you stay safe! It is annoying to continuously breathe down someone’s neck for payments. The software for billing in small business is very perfect for both customer care and business. It also retains the name small business by performing most of the tasks alone.",
                    "imgSrc": "/views/images/search_export_api.png",
                    "imgTitle" : "Export"
                }
            ]
        }
     };
}]);

/*accounting book page*/
app.controller('accountingBookController', ['$scope',function ($scope){
     $scope.accountingbook = {
        "middle": {
            "list":[
                {
                    "title" : "Accounting book ",
                    "details" : "Is it a headache to make all hell lot of entries under the category of journal, ledger, trading account, Profit & Loss account, balance sheet and what not? After all an accounting book is a package of all financial statements entangled together in order to keep financial records, isn’t it? But what if all this is done by the software where in you just have to simply write it in simple words.",
                    "imgSrc": "/views/images/online_on_cloud.png",
                    "imgTitle" : "Online on Cloud"
                },
                {
                    "title" : "Account book software",
                    "details" : "You no longer have to strain your grey matter understanding the financial statements. The account book software systematically records, reports, understands and analyses all the financial transactions. Also, it analytically forms a report (balance sheet) to be presented to you. It is prepared in no time as compared to the time it would have taken to be computed manually. So this report is accurate, fast and exactly what you have been looking for.",
                    "imgSrc": "/views/images/no_need_to_learn.png",
                    "imgTitle" : "No need to learn"
                },
                {
                    "title" : "Book keeping software ",
                    "details" : "Is anything simple in the world of accounting? Yes book keeping is by Joe! It easily tells you about the profits generated by the organization. Book keeping is systematic recording of the financial transactions. And with the help of book keeping software it gets even easier to manage all the financial transactions and accounts. It is faster and systematic as well as accurate so you need not worry!",
                    "imgSrc": "/views/images/secure.png",
                    "imgTitle" : "Secure"
                },
                {
                    "title" : "All in one ",
                    "details" : "Unlike accounts book you don’t have to make several different entries. Just a handful of simple words ask you about the transaction you have just made and that is it! Rest all is done by the software. This way it does the task of many people all by itself, reducing the labor cost. And on top of it, it is very fast, accurate and as perfect as you want!",
                    "imgSrc": "/views/images/multi_user.png",
                    "imgTitle" : "Multiple User"
                },
                {
                    "title" : "Benifits",
                    "details" : "You get the freedom to travel in space and time with the book keeping software. Your data can be accessed by anyone you allow at any time from any place. It is more cost effective and convenient for everyone around you in the accounting department. Your data can be shared and modified easily without the hassle of data transference. It highly reduces the risk of operational errors as it is all done mechanically by the software.",
                    "imgSrc": "/views/images/recursive_entry.png",
                    "imgTitle" : "Recursive Entry"
                },
                {
                    "title" : "For Startups",
                    "details" : "You have plenty of tasks other than maintaining accounts book, right? Go ahead and take up all the tasks that need your attention at first. Accounts will be managed by the software more accurately than you could have even thought of! It will help you grow prominently and the business flourishes more flawlessly. The accuracy of the results can be matched by that of any expert in terms of computing.",
                    "imgSrc": "/views/images/search_export_api.png",
                    "imgTitle" : "Export"
                }
            ]
        }
     };
}]);

/*accounting software page*/
app.controller('accountingSoftwareController', ['$scope',function ($scope){
     $scope.accountingsoftware = {
        "middle": {
            "list":[
                {
                    "title" : "For me?",
                    "details" : "Do you have butterflies in the stomach when you hear the task of accounting? Is it really this complex? Well, need is the mother of invention. It is extremely easy when you use Giddh as your accounting tool. We have broken down the complexity of accounts into simple ABCs which readily fits into any type and size of brain. This software is not just accounting software but the only ACCOUNTING SOFTWARE of its kind.",
                    "imgSrc": "/views/images/online_on_cloud.png",
                    "imgTitle" : "Online on Cloud"
                },
                {
                    "title" : "M different!",
                    "details" : "This easy accounts software is unique in many ways. Unlike other accounting software it is not desktop software but online accounting software. This means it elates your wings with internet to work while you fly places. Your data is available on cloud computing and not stored on any specific â€œaccounting systemâ€? to be accessed at any time. This makes it more convenient, reliable, and consistent, free of theft, and free of updating as it updates on its own.",
                    "imgSrc": "/views/images/no_need_to_learn.png",
                    "imgTitle" : "No need to learn"
                },
                {
                    "title" : "Accounts simplified!",
                    "details" : "Usually when it comes to financial and accounting software it is implicit that the user is well acquainted with the accounting jargons like assets, liabilities, credits, debts, balance sheet, inventory, capital, cash flow, depreciation, appreciation, fixed and variable costs, etc. Seems gibberish? We have this simple accounting software which talks in the language that you understand! Giddh works just like a handbook in which you enter the details of your transaction and that is it.",
                    "imgSrc": "/views/images/secure.png",
                    "imgTitle" : "Secure"
                },
                {
                    "title" : "Worry not!",
                    "details" : "You need not worry about financial statements, graphical presentations, balance sheet and hell lot of ratios ranging from the turnover ratios, profitability ratios, and liquidity ratios. This accounting software for business is designed to serve it all to you. It transforms your data in the form of several charts and graphs. You can just be happy after entering the basic transactions and gear yourself to simply analyze the reports served to you by Giddh.",
                    "imgSrc": "/views/images/multi_user.png",
                    "imgTitle" : "Multiple User"
                },
                {
                    "title" : "Why me?",
                    "details" : "The basic purpose of any business accounting software is to ameliorate its profits. A business not only grows by its production or sales but also by its internal processes. Finance department is such a big process in any organization that its perfection directly affects the future and profits of the company. Financial accounting software reduces down all the complexity to simple analysis. Finance department of any organization is usually considered as a very complex department.",
                    "imgSrc": "/views/images/recursive_entry.png",
                    "imgTitle" : "Recursive Entry"
                },
                {
                    "title" : "Profits",
                    "details" : "With the launch of online accounting software finances of the company have become very handy. The users no longer have to sit glued to one PC to get all the accounting details. It can be accessed at any time by any hand held gizmo or for that matters any internet enabled device as it offers home accounting software as well. This freedom of space and time in web accounting software is just awesome!",
                    "imgSrc": "/views/images/search_export_api.png",
                    "imgTitle" : "Export"
                }
            ]
        }
     };
}]);
