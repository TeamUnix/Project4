<?php
	
	// SQL request for the device page.
	require_once("includes/db_connect.php");
	
	if(isset($_GET['cmd']) && isset($_GET['id_module'])){
		
		$device_port = 5555;
			
		$sql= "SELECT IP ". 
			  "FROM `DEVICE` ". 
			  "ORDER BY ID_DEVICE DESC ".
			  "LIMIT 1";
		
		$res = $con->query($sql); // Run the query in the MySQL server
		
		$row = $res->fetch_row();
		
		$device_ip = $row[0];
		
		if (!$socket=socket_create(AF_INET, SOCK_STREAM, SOL_TCP)){
			exit (socket_strerror(socket_last_error()));
		}
	
		if (!socket_connect($socket,$device_ip,$device_port)){
			exit (socket_strerror(socket_last_error()));
		}
	
		$str = $_GET['cmd'].';'.$_GET['id_module'].';'.$_GET['dir'];
		
		socket_write($socket,$str);
	
		$msg='';
		$c='';
    	
		while(socket_recv($socket, $c, 256,0)){
  			if($c != null) {
   				$msg .= $c;
			}
		}
		
		echo $msg;
        
		socket_close($socket);
		
	} else {
		echo 'Command or Module Id not set';
	}

?>