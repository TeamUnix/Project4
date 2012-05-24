// JavaScript Document

function printActions(obj,id,id_stat){
	//alert(id);
	switch(id_stat){
			case '1': obj.innerHTML = '<a href="#" onclick="sendCmd('+id+',\'s\')">Start</a>'; break;
			case '2': obj.innerHTML = '<a href="#" onclick="sendCmd('+id+',\'c\')">Connect</a>'; break;
			case '3': obj.innerHTML = '<a href="#" onclick="sendCmd('+id+',\'p\')">Stop</a>'; break
			case '4': obj.innerHTML = '<a href="#" onclick="sendCmd('+id+',\'s\')">Start</a>'; break
			default: obj.innerHTML = ''; break;
	}
}

function getData(str,id){
	
	var req;
	var result;
	var x;
	
	if(window.XMLHttpRequest){
		req	= new XMLHttpRequest();
	} else {
		req = ActiveXObject("Microsoft.XMLHTTP");	
	}

	//req.open("POST",str+"getData.php",false);
	req.open("POST","getData.php",false);
	req.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	
	req.send("unique_id="+id);
	
	//alert (req.responseText);
	
	result = req.responseXML;

	x = result.getElementsByTagName("DATA");
	
	c_pw_pro.innerHTML = x[0].getElementsByTagName("C_PW_PRO")[0].childNodes[0].nodeValue;
	c_pw_con.innerHTML = x[0].getElementsByTagName("C_PW_CON")[0].childNodes[0].nodeValue;
	tt_pw_pro.innerHTML = x[0].getElementsByTagName("TT_PW_PRO")[0].childNodes[0].nodeValue;
	avg_pw_pro.innerHTML = x[0].getElementsByTagName("AVG_PW_PRO")[0].childNodes[0].nodeValue;
	uptime.innerHTML = x[0].getElementsByTagName("UPTIME")[0].childNodes[0].nodeValue;
	stat.innerHTML = x[0].getElementsByTagName("STAT")[0].childNodes[0].nodeValue;
	
	module1.innerHTML = '<a href="?page='+x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue+'"><img src="'+x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue+'/header.png" alt="'+x[0].getElementsByTagName("M1")[0].attributes[1].nodeValue+'"/></a>';
	module2.innerHTML = '<a href="?page='+x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue+'"><img src="'+x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue+'/header.png" alt="'+x[0].getElementsByTagName("M2")[0].attributes[1].nodeValue+'"/></a>';
	
	m0_stat.innerHTML = x[0].getElementsByTagName("STAT")[0].childNodes[0].nodeValue;
	
	m1_stat.innerHTML = x[0].getElementsByTagName("M1")[0].attributes[2].nodeValue;
	m2_stat.innerHTML = x[0].getElementsByTagName("M2")[0].attributes[2].nodeValue;
	
	var priv = x[0].getElementsByTagName("PRIV")[0].childNodes[0].nodeValue;
	
	var dev_error = x[0].getElementsByTagName("DEV_ERROR")[0].childNodes[0].nodeValue;
	
	var id_stat = x[0].getElementsByTagName("STAT")[0].attributes[0].nodeValue;
	
	if (priv>0){
				
				if(dev_error==0){
					printActions(act_0,0,id_stat);
				} else {
					printActions(act_0,0,0);
				}
			
				if(dev_error==0){
					var stat_id_m1 = x[0].getElementsByTagName("M1")[0].attributes[3].nodeValue;
					printActions(act_1,x[0].getElementsByTagName("M1")[0].attributes[0].nodeValue,stat_id_m1);
				} else {
					printActions(act_1,0,0);
				}
				
				if(dev_error==0){
					var stat_id_m2 = x[0].getElementsByTagName("M2")[0].attributes[3].nodeValue;
					printActions(act_2,x[0].getElementsByTagName("M2")[0].attributes[0].nodeValue,stat_id_m2);
				} else {
					printActions(act_2,0,0);
				}
	}
	
}

function sendCmd(module_id,cmd){
	
	var req;
	var result;
	var x;
	
	if(window.XMLHttpRequest){
		req	= new XMLHttpRequest();
	} else {
		req = ActiveXObject("Microsoft.XMLHTTP");	
	}
	
	req.open("GET","../sendcmd.php?id_module="+module_id+"&cmd="+cmd,false);
	req.send();
	
	answer = req.responseText;
	
	if(parseInt(answer)==1){
		// Command executed with success
		//alert("ID: "+module_id+"\nCmd:"+cmd+"\nOK");
		
		switch(cmd){
			case 'c': id_status=1; break;
			case 's': id_status=3; break;
			case 'p': id_status=4; break;
		}
		
		req.open("GET","./0/savedata.php?op=status&id_module="+module_id+"&id_status="+id_status,false);
		req.send();
	
	} else {
		// Alert user that the status of the modules was not changed
		alert("ID: "+module_id+"\nCmd:"+cmd+"\nNOK");	
	}
	
}
