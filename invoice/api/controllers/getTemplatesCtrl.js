const fs = require('fs');
//cont webshot = require('webshot');

getTemplates = {}
var html_template_path = './invoice/api/models/invoice/html_templates/'

function templateObject (){
	this.template = {}
	this.template.name = ""
	this.template.htmlString = ""
	this.template.id = ""
}

function returnFileAsHtmlString (fileName, callback){
var d;
fs.readFile(html_template_path+fileName,"utf-8", function(err, data){
    if (err) {
      return console.error("Invalid template id");
    }
     callback(data)
    })
}

function getById(req,res,next){
	template_id= req.body.invoice_id;
	template_name = "template_"+template_id+".html";
	console.log(template_name);
	var a = returnFileAsHtmlString(template_name,function(data){
      res.status(200).send(data);
	});
}




function returnAllWithoutAuth(req,res,next){

fs.readdir(html_template_path,function(err, files){
   if (err) {
      return console.error(err);
    }
    files.forEach(function (file){
    

});

});
    
}












function returnAll (req, res, next){
	console.log("HEYEEYEYE")
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
getTemplates.returnAll = returnAll;
getTemplates.getById = getById;
getTemplates.returnAllWithoutAuth = returnAllWithoutAuth;

module.exports = getTemplates;