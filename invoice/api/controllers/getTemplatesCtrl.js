const fs = require('fs');
const settings = require('../../../public/routes/util/settings');

getTemplates = {}
var html_template_path = 	'./invoice/api/models/invoice/html_templates/'
var html_template_image_path ='./invoice/api/models/invoice/html_templates/template_images/'
function template (){
	this.image_src=""
	this.id=""
}

function templateData(){
	this.id = ""
	this.name = ""
	this.html = ""
}


function returnFileAsHtmlString (fileName, callback){
console.log(html_template_path+fileName);
fs.readFile(html_template_path+fileName,"utf-8", function(err, data){
    if (err) {
      return console.log("Invalid template id")
    }
     callback(data)
    })
}

function getById(req,res,next){
	var template = new templateData();
    template.id = req.params.id; 
	template.name = template.id +'.html';
	returnFileAsHtmlString(template.name,function(data){
	template.html = data
	res.status(200).send(template);
	});
    
}


function returnAllWithoutAuth(req,res,next){
	var filesToReturn = [];
	var fileObj;
	fs.readdir(html_template_image_path,
		function(err, files){
		    if (err) {
		      return console.error(err);
		    }
		    files.forEach(function (file){
			    fileObj = new template();
			    fileObj.image_src = settings.domainURL+html_template_image_path.substring(1,html_template_image_path.length)+file
				fileObj.id = file.substring(file.length - 4, -file.length);
				filesToReturn.push(fileObj)	
	  		});
			res.status(200).send(filesToReturn)   
		}
	);
}


function returnAll (req, res, next){
 filesToReturn = [];	
 fs.readdir("./invoice/api/models/invoice/html_templates/",function(err, files){
   if (err) {
      return console.error(err);
    }	

   files.forEach(function (file){
     // console.log(returnFileAsHtmlString("./api/models/invoice/html templates/"+file));
      fileObj = new templateObject();
	  fileObj.name = file
	  fileObj.htmlString = returnFileAsHtmlString("./api/models/invoice/html_templates/"+file)
	  fileObj.data = "this is the data"
	  filesToReturn.push(fileObj)
   });
	if(files.length == filesToReturn.length){
		resObj = {}
		resObj.templates = filesToReturn
		res.status(200).send(resObj)
	}else{
		console.log("else")
	}
});
    
}



// return all templates
getTemplates.getById = getById;
getTemplates.returnAllWithoutAuth = returnAllWithoutAuth;



module.exports = getTemplates;