

var scriptToImport = [
    '/bower_components/modernizr/modernizr.js',
    '/bower_components/jquery/jquery.min.js',
    "/bower_components/angular/angular.min.js",
    "/bower_components/angular-resource/angular-resource.min.js",
    "/bower_components/angular-route/angular-route.js",
    "/bower_components/angular-sanitize/angular-sanitize.js",
    "/bower_components/angular-local-storage/dist/angular-local-storage.js",
    "/bower_components/bootstrap/dist/js/bootstrap.min.js",
    "/bower_components/satellizer/satellizer.js",
    "/public/website/js/app.js",
    "/public/website/js/controller/homeController.js",
    "/public/website/js/controller/loginController.js",
    "/public/website/js/service/loginService.js",
    "/public/website/js/controller/allPageController.js",
    "/public/website/js/controller/contactController.js",
    "/public/website/js/controller/pricingController.js",
  "/public/website/js/controller/versionController.js"
]

function loadScript(url, callback){
  var script = document.createElement("script")
  script.type = "text/javascript";

  if (script.readyState){  //IE
    script.onreadystatechange = function(){
      if (script.readyState == "loaded" ||
          script.readyState == "complete"){
        script.onreadystatechange = null;
        callback();
      }
    };
  } else {  //Others
    script.onload = function(){
      callback();
    };
  }

  script.src = url;
  document.getElementsByTagName("head")[0].appendChild(script)

}


for (i = 0; i < scriptToImport.length; i++) {
  loadScript(scriptToImport[i], function(){
    //do something if needed
  });

}

