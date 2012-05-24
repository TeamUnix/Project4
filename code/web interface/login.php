<?php

	session_start(); // Starts the Session
	
	require_once("includes/db_connect.php"); // Include the database connection
	
	if (isset($_POST['logout'])){ // If logout is set by PORT encoded URL request
		
		echo "logout";			  // Return logout for the javascript
		$_SESSION['priv']=0;	  // Set the priv to 0
		
	} else if(isset($_POST['user']) && isset($_POST['pass'])){
		
		$sql = "SELECT ID_PRIV, ID_USER FROM `USERS` WHERE NAME='".$_POST['user']."'AND PASS='".$_POST['pass']."'"; // SQL statment contruction ( ATENTION this method have no encryption, you can add it by yourselfs)
		
		$res = $con->query($sql); // MySQL request

		if ($res->num_rows==1){ // See if any value is returned, if true assign priveledge to session priv.
			
			$row = $res->fetch_row();	
			$_SESSION['priv']=$row[0];
			$_SESSION['id_user']= $row[1];
			$_SESSION['user']=$_POST['user'];
			echo "ok";
		} else {
			echo "Wrong credentials";
		}
	}
?>