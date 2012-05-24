<?php
	session_start();
	
	require_once("errorhandler.php");
	
	require_once("includes/db_connect.php");
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
        <link rel="stylesheet" type="text/css" href="reset.css" />
        <link rel="stylesheet" type="text/css" href="style_index.css" />
        <link rel="stylesheet" type="text/css" href="includes/popStyle.css" />
		<title>Energy System - HIH E10</title>
       	<script src="includes/popUp.js" language="javascript" type="text/javascript"></script>
        <script src="con_control.js" language="javascript" type="text/javascript"></script>
        
	</head>
    
   
	<body>
        
   	<div id="bg">
    	<img src="pic/background.png" alt="background"/>
	</div>
	
    <div id="modules">
 		<div id="m1" class="boxbg"></div>
        <div id="hub" class="boxbg"><a href="modules/?page=0"><img src="pic/hub_big.png" alt="HUB Module"/></a></div>
   		<div id="m2" class="boxbg"></div>
	</div>
	

	<div id="linebox">
        <div class="energyboxes" id="bulb">
            <h1>x ##</h1>
        </div>
        <div class="energyboxes" id="coins">
            <h1>## kr</h1>
        </div>
        <div class="energyboxes" id="co2">
            <h1>## g</h1>
        </div>
    </div>
    
	<div id="dock">
        	<a href="#"> <img src="pic/dock_home.png" alt="home" /></a>
            <?php if(isset($_SESSION['priv']) && $_SESSION['priv']>0){ ?>
            		<a href="#" onClick="logout('')"> <img src="pic/dock_key_open.png" alt="key_locked" name="0" id="lock" /> 	</a>
            <?php } else { ?>
            		<a href="#" onClick="login('')"> <img src="pic/dock_key_lock.png" alt="key_locked" name="1" id="lock" /> 	</a>
            <?php } ?>
		</div>
	<div id="dot">
        	<img src="pic/dot.png" alt="dot" />
        </div>
    <script>
			//function layout(){
				
				// Define Size and center
				var x = window.innerWidth;
				var y = window.innerHeight;
				
				var width = 800;
				var height = 200;
				
				//box.style.position = "absolute";
				modules.style.left = (x/2)-(width/1.8) + 'px';
				modules.style.top = (y/2)-(height/2)-150 + 'px';
				
				/*
				m1.style.top = (y/3)-(height/2)-50 + 'px';
				m1.style.left = (x/3)-(width/2) + 'px';
				
				m2.style.top = (y/3)-(height/2)-50 + 'px';
				m2.style.left = (x/1.18)-(width/2) + 'px';
				*/
				// Ensure that it comes to the front.
				module.style.zIndex = '999';	
				
			//}
	</script>
    
    <script>getData(); setInterval('getData()',1000);</script>
</body>
</html>
