// JavaScript Document


function getData(){
	
	var req;
	var result;
	var x;
	
	if(window.XMLHttpRequest){
		req	= new XMLHttpRequest();
	} else {
		req = ActiveXObject("Microsoft.XMLHTTP");	
	}

	req.open("GET","con_data.php",false);
	req.overrideMimeType('text/xml');
	req.send();
	
	result = req.responseXML;

	x = result.getElementsByTagName("DATA");
	
	var m1_stat = x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue;
	var m2_stat = x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue;
	
	if(m1_stat!=""){ 
		m1.innerHTML = '<a href="modules/?page='+x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue+'"><img src="pic/'+x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue+'.png" alt="'+x[0].getElementsByTagName("M1")[0].attributes[1].nodeValue+'"/></a>'; 
		m1.style.display = "inline-block";
	} else { 
		m1.innerHTML = "" 
		m1.style.display = "none";
	}
	
	if(m2_stat!=""){ 
		m2.innerHTML= '<a href="modules/?page='+x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue+'"><img src="pic/'+x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue+'.png" alt="'+x[0].getElementsByTagName("M2")[0].attributes[1].nodeValue+'"/></a>';
		m2.style.display = "inline-block";
	} else { 
		m2.innerHTML = "" 
		m2.style.display = "none";
	}

}
