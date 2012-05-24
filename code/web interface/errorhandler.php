<?php
	
	session_start();
	
	if ($_SESSION['error_db']>1) { 
		$_SESSION['error_db']=0;
	}
	
	$_SESSION['error_device']=0;
	
	// Test DB connection
	require_once("includes/db_globals.php");
	
	$con = mysql_connect(DB_HOST,DB_USER,DB_PASS,DB_NAME);
	
	if(!$con){
		$_SESSION['error_db']=1;
		$error = "Failed to connect to database: ". mysql_error();
	} else {
		if ($_SESSION['error_db']==1){
			$_SESSION['error_db']=2;
		} else {
			$_SESSION['error_db']=0;	
		}
	}

	// Test Device connection
	if($_SESSION['error_db']==0){
		
		$device_port = 5555;
		
		$con = new mysqli(DB_HOST,DB_USER,DB_PASS,DB_NAME);
		
		$sql= "SELECT IP ". 
			  "FROM `DEVICE` ". 
			  "ORDER BY ID_DEVICE DESC ".
			  "LIMIT 1";
		
		$res = $con->query($sql);
		
		$row = $res->fetch_row();
		
		$device_ip = $row[0];
		
		if (!$socket=socket_create(AF_INET, SOCK_STREAM, SOL_TCP)){
			$_SESSION['error_device']=1;
		} else {
			$_SESSION['error_device']=0;
		}
	
		if (!socket_connect($socket,$device_ip,$device_port)){
			
			$_SESSION['error_device']=1;
		} else {
			$_SESSION['error_device']=0;
		}
		
		socket_write($socket,"a");
		
		socket_close($socket);
	
	}

	if(isset($_GET['op']) && $_GET['op']=='d'){
		
		echo '<ERROR>'.
			    '<DB>'.$_SESSION['error_db'].'</DB>'.
				'<DEVICE>'.$_SESSION['error_device'].'</DEVICE>'.
			  '</ERROR>';
		
	} else {
		
?>
<style>

#db_div{
	z-index: 9999;
	position:absolute;
	border:2px solid #000;
	-moz-border-radius: 15px;
 	border-radius: 15px;	
	background: #FFF;
}

#bg_div{
	background: #000;
	position: absolute;
	left: 0px;
	top: 0px;
	width: 100%;
	height: 100%;
	opacity: 0.8;
	z-index: 0;	
}

#db_div img {
	padding-top: 15%;
}

#box_dev{
	right: 10px;
	top: -142px;
	z-index: 9999;
	position:absolute;
	border:2px solid #666;
	-moz-border-left-radius: 15px;
	-moz-border-right-radius: 15px;
 	border-bottom-left-radius: 15px;
	border-bottom-right-radius: 15px;
	background: #FFF;
	font-size:10px;
	width:150px;
	height:140px;
}

</style>
<?php

		if(isset($_SESSION['error_db']) && $_SESSION['error_db']==1){
?>

<center>
	<div id="db_div">
    	<img src="/includes/images/db_error.png" />
       <p><?php echo $error; ?></p>
       <input type="button" value="Retry" onclick="location.reload(true);"/>
    </div>
</center>

<div id="bg_div">
</div>

<script language="javascript" type="text/javascript">

	var width = 600;
	var height = 500;
	
	// Define Size and center
	var x = window.innerWidth;
	var y = window.innerHeight;
	
	var box = document.getElementById('db_div');
	
	box.style.left = (x/2)-(width/2) + 'px';
	box.style.top = (y/2)-(height/2)-50 + 'px';
	box.style.width = width + 'px';
	box.style.height = height + 'px';
	
</script>
  
<?php
		echo '<script src="error.js" language="javascript" type="text/javascript"></script>';
		exit();
		}
		if($_SESSION['error_device']==1){
?>
		<div id="box_dev" style="top: -2px;">
			<center>
            	<img src="/includes/images/dev_error.png" /><p>Connection to the device failed.<a href="#" onclick="makeTests();">Retry</a></p>
        	</center>
        </div>
<?php
		}
	echo '<script src="error.js" language="javascript" type="text/javascript"></script>';
	}
?>
