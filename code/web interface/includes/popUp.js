/*
*
*	Author: Paulo Miguel Fontes
*	
*	Description: Creates and show a login, fading the background.	
*
*/

function senCred(type,str){
		
	switch(parseInt(type)){
		case 1:{	
				var user = txt_user.value;
				var pass = txt_pass.value;
				break
				}
	}
	
	var req;
	if(window.XMLHttpRequest){
		req	= new XMLHttpRequest();
	} else {
		req = ActiveXObject("Microsoft.XMLHTTP");	
	}

	req.open("POST",str+"login.php",false);
	req.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	
		switch(parseInt(type)){
			case 0: {	
				req.send("logout=1");
				location.reload(true);
				break;
				} 
			case 1:{	
				req.send("user="+user+"&pass="+pass);
				if (req.responseText=="ok"){
					popClose();
					location.reload(true);
				} else {
					err.innerHTML = req.responseText;
				}
				break
				}
		}
}

function createBg(){
	// Create black background
	var bg_div = document.createElement('div');
	bg_div.style.background = "#000";
	bg_div.id = "bg_div";
	
	// Resize background and fit page
	bg_div.style.position = "absolute";
	bg_div.style.left = '0px';
	bg_div.style.top ='0px';
	bg_div.style.width = '100%';
	bg_div.style.height = '100%';
	
	// Change opacacy
	bg_div.style.opacity = '0.8';
	
	// Ensure that it comes to the front.
	bg_div.style.zIndex = '999';
	
	// Append background
	document.body.appendChild(bg_div);
	
}

function popClose(){
	
	// Declares the background and box objects reference.
	var box_div = document.getElementById('box_div');
	var bg_div = document.getElementById('bg_div');
	
	// Removes the objects from body.
	document.body.removeChild(box_div);
	document.body.removeChild(bg_div);
	
}

function logout(str){
	senCred(0,str);
}

function login(str){
		
	var text;
	
	text = '<center><div style="padding-top:10px:">'
			+'	<div>Username</div>'
    		+'	<div><input type="text" id="txt_user" /></div>'
    		+'	<br /><div>Password</div>'
    		+'	<div><input type="password" id="txt_pass" /></div>'
			+'</div></center>';
	
	createBg();
	
	var title = "Administrator Login"	;
	var width = 300;
	var height = 200;	
	
	var btn_ok = '<a href="#"><img id="btn_ok" src="'+str+'includes/images/ok.png" onclick="senCred(1,\''+str+'\')"/></a>'; // An action is going to be added to onclick event. 
	var btn_close = '<a href="#"><img id="btn_cancel" src="'+str+'includes/images/cancel.png" onclick="popClose();" style="padding-left:20px;"/></a>';
	
	// Create white backbox
	var box = document.createElement('div');
	box.style.background = "#FFF";
	box.id = "box_div";
	
	// Define Size and center
	var x = window.innerWidth;
	var y = window.innerHeight;
	
	//box.style.position = "absolute";
	box.style.left = (x/2)-(width/2) + 'px';
	box.style.top = (y/2)-(height/2)-50 + 'px';
	box.style.width = width + 'px';
	box.style.height = height + 'px';
	
	// Ensure that it comes to the front.
	box.style.zIndex = '9999';
	
	// Inner Text
	box.innerHTML =  '<div id="box_title" align="center">'+ title +'</div>'
					+'<div id="box_main" style="padding-left: 10px; padding_top:10px; height: ' + (height-90) + 'px">'+ text +'<center><div id="err"></div></center></div>'
					+'<div id="box_footer" style="height: 20px;" align="center">' + btn_ok + btn_close + '</div>';
	// Append Text
	document.body.appendChild(box);
	
	txt_user.focus();
	
}

