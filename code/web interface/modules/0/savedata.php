<?php
	
	session_start();
	
	require_once("db_connect.php");
	
	/*
	*	Save Data to the MySQL database.
	*	
	*	Description: This script allows the user to add values to the database, if no options are given, by default it will assume that the request is to save data to the table measurements.
	*	
	*	Parameters: 
			sensor_id: Id of the sensor to where save data.
			value: the vlue to be saved
			hub_port: the connected port of the module
			
			op: extra options for the script.
				status: change status of a module. <unique_id><new status>, this is added to the log table.
	*
	*/
	
	
	// savedata.php?op=status&id_module=2&id_status=1&hub_port=1
	function changeStatus($con){
		$date = getdate();

		$today = $date['year'].'-'.$date['mon'].'-'.$date['mday'].' '.$date['hours'].':'.$date['minutes'].':'.$date['seconds'];
		
		$sql = 'INSERT INTO `iEnergy`.`LOGS` (
				`ID_LOG` ,
				`ID_MODULE` ,
				`DATE_TIME` ,
				`ID_STATUS` ,
				`ID_USER` ,
				`ID_ERROR` 
				)
				VALUES (
				NULL , \''.$_GET['id_module'].'\', \''.$today.'\', \''.$_GET['id_status'].'\', \''.$_SESSION['id_user'].'\', \'1\'
				)';
		
		if($con->query($sql)){
			echo "Success";
		}
		
		$sql = 'UPDATE `iEnergy`.`MODULES` SET `HUB_PORT` = '.$_GET['hub_port'].' WHERE `MODULES`.`UNIQUE_ID` ='.$_GET['id_module'];
		
		if($con->query($sql)){
			echo "Success";
		}
	}
	
	if(isset($_GET['op'])){
		
		switch ($_GET['op']){
			case "status": changeStatus($con); break;	
		}
		
	} else {
		$date = getdate();

		$today = $date['year'].'-'.$date['mon'].'-'.$date['mday'].' '.$date['hours'].':'.$date['minutes'].':'.$date['seconds'];

		if(isset($_GET['sensor_id']) && isset($_GET['value']) && isset($_GET['hub_port'])){
			$sql= "INSERT INTO `iEnergy`.`MEASUREMENTS` (".
				  "`ID_MEASURE` ,".
			  	  "`ID_SENSOR` ,".
			  	  "`DATE_TIME` ,".
			  	  "`HUB_PORT` ,".
			  	  "`VALUE`) ".
			  	  "VALUES (NULL , '".$_GET['sensor_id']."', '".$today."', '".$_GET['hub_port']."', '".$_GET['value']."')";
	
			$con->query($sql); // Run the query in the MySQL server
			echo $sql;
		}	else {
			echo 'Invalide parameters';	
		}
	}
	
?>