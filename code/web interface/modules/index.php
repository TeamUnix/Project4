<script src="../error.js" language="javascript" type="text/javascript"></script>
<?php
	session_start();
	
	require_once("../errorhandler.php");
	require_once("../includes/db_connect.php");
	
	$sql= "SELECT NAME ". 
		  "FROM `MODULES` ". 
	      "WHERE UNIQUE_ID = ".$_GET['page'];
	
	$res = $con->query($sql); // Run the query in the MySQL server
	
	$row = $res->fetch_row();
		
	$name = $row[0];
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initital-scale=1, user-scalable=no" />
    <link rel="stylesheet" type="text/css" href="../reset.css" />
    <link rel="stylesheet" type="text/css" href="module_styles.css" />
    <link rel="stylesheet" type="text/css" href="<?php echo $_GET['page']."/"; ?>style.css" />
	<title>Energy Hub - HIH E10</title>
   		<link rel="stylesheet" type="text/css" href="../includes/popStyle.css" />
		<script src="../includes/popUp.js" language="javascript" type="text/javascript"></script>
        <script>
			function layout(){
				
				// Define Size and center
				var x = window.innerWidth;
				var y = window.innerHeight;
				
				var width = 930;
				var height = 500;
				
				if(y<728){
					height = 300;
				}
				
				//box.style.position = "absolute";
				main.style.left = (x/2)-(width/2) + 'px';
				main.style.top = (y/2)-(height/2)-50 + 'px';
				
				// Ensure that it comes to the front.
				main.style.zIndex = '999';	
				
			}
		</script>
	</head>
	<body onload="layout()">
   	<div id="bg">
    	<img src="../pic/background.png" alt="background"/>
	</div>
        <div id="header">
        	<img src="<?php echo $_GET['page']; ?>/header.png" alt="HUB_module"/>
            <h1 id="name"><?php echo $name; ?></h1>
        </div>
			
		<div id="main">
			<?php include($_GET['page']."/index.php"); ?>
		</div>

		<div id="dock">
        	<?php include("dock.php"); ?>
        </div>
</body>
</html>
