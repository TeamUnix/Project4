// JavaScript Document
var delay=2000;
function animate_down(obj,next,last){
	setTimeout(function (){
		if(next<=last){		
			obj.style.top = next;
			next+=10;
		}
		animate_down(obj,next,last);
	}, 1);
}

function animate_up(obj,next,last){
	setTimeout(function (){
		if(next>=last){		
			obj.style.top = next;
			next-=10;
		} else {
			document.body.removeChild(document.getElementById('box_dev'));	
		}
		animate_up(obj,next,last);
	}, 1);
}

var bd_err = true;
var dev_err = true;

function makeTests(){
	var req;
	var db_error;
	var dev_error;
	
	if(window.XMLHttpRequest){
		req	= new XMLHttpRequest();
	} else {
		req = ActiveXObject("Microsoft.XMLHTTP");	
	}

	req.open("GET","/errorhandler.php?op=d",false);
	req.overrideMimeType('text/xml');
	req.send();
	
	var result = req.responseXML;
	
	x = result.getElementsByTagName("ERROR");
	
	db_error = x[0].getElementsByTagName("DB")[0].childNodes[0].nodeValue;
	dev_error = x[0].getElementsByTagName("DEVICE")[0].childNodes[0].nodeValue;
	
	if(db_error==1){
		location.reload(true);
	} else if(db_error==2) {
		location.reload(true);
	}
	
	if(dev_error==1 && dev_err){
			
		if(document.getElementById('box_dev')==null){
			var box_dev = document.createElement('div');
			box_dev.id = "box_dev";
			box_dev.innerHTML = '<center><img src="/includes/images/dev_error.png" /><p>Connection to the device failed.<a href="#" onclick="makeTests();">Retry</a></p></div></center>';
			document.body.appendChild(box_dev);
			animate_down(box_dev,box_dev.offsetTop,-2);
		} 
		
		dev_err=false;
		
	} else if(dev_error==0 && !dev_err) {
		// Declares the background and box objects reference.
		var box_dev = document.getElementById('box_dev');
		animate_up(box_dev,box_dev.offsetTop,-142);
		dev_err=true;
	}
}

setInterval('makeTests()',delay);