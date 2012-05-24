<?php
	
	require_once("db_connect.php");
	
	
	if(isset($_GET['ip'])){
		$sql= "INSERT INTO `iEnergy`.`DEVICE` (".
			  "`ID_DEVICE` ,".
		  	  "`IP`)".
		  	  "VALUES (NULL , '".$_GET['ip']."')";
	
		$con->query($sql); // Run the query in the MySQL server
		
		// No feedback needed since the energy hub will not expect an answer.
		
	} else {
		echo 'IP not set';
	}
	
?>