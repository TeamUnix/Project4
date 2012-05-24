<?php

	session_start();

	require_once("db_connect.php");

	$voltage = 30;
	
	// Current Power Production
	$sql = "SELECT VALUE FROM `MEASUREMENTS` WHERE `ID_SENSOR`=".$_POST['unique_id']." AND VALUE>0 ORDER BY ID_MEASURE DESC LIMIT 1";
	$res = $con->query($sql);
	$row = $res->fetch_row();
	$c_pw_pro = ($row[0]*$voltage)."W ";
	
	// Current Power Production
	$sql = "SELECT VALUE FROM `MEASUREMENTS` WHERE `ID_SENSOR`=".$_POST['unique_id']." AND VALUE<0 ORDER BY ID_MEASURE DESC LIMIT 1";
	$res = $con->query($sql);
	$row = $res->fetch_row();
	$c_pw_con = ($row[0]*$voltage*-1)."W ";

	// Total Power Production
	//$sql = "SELECT SUM(VALUE) FROM `MEASUREMENTS` WHERE `ID_SENSOR`=".$_POST['unique_id'];
	$sql = 'SELECT SUM(VALUE) 
			FROM `MEASUREMENTS` 
			WHERE `ID_SENSOR`='.$_POST['unique_id'].'
			AND DATE_TIME>(SELECT DATE_TIME FROM LOGS WHERE ID_MODULE='.$_POST['unique_id'].' ORDER BY DATE_TIME DESC LIMIT 1)';
	$res = $con->query($sql);
	$row = $res->fetch_row();
	$tt_pw_pro = ($row[0]*$voltage)."W ";
		
	// Average Power Production
	//$sql = "SELECT VALUE FROM `MEASUREMENTS` WHERE `ID_SENSOR`=".$_POST['unique_id'];
	$sql = 'SELECT AVG(VALUE) 
			FROM `MEASUREMENTS` 
			WHERE `ID_SENSOR`='.$_POST['unique_id'].'
			AND DATE_TIME>(SELECT DATE_TIME FROM LOGS WHERE ID_MODULE='.$_POST['unique_id'].' ORDER BY DATE_TIME DESC LIMIT 1)';
	$res = $con->query($sql);
	$row = $res->fetch_row();
	$avg_pw_pro = ($row[0]*30)."W ";
	
	// Status
	if($_SESSION['error_device']==1){
		$stat = "Connection Failed";
	} else {
	
	$sql = 'SELECT `STATUS`.NAME, `STATUS`.ID_STATUS
			FROM `LOGS` , `STATUS`
			WHERE `STATUS`.ID_STATUS = `LOGS`.ID_STATUS AND `ID_MODULE`='.$_POST['unique_id'].'
			ORDER BY `LOGS`.ID_LOG DESC 
			LIMIT 1 ';
	
	$res = $con->query($sql);
	$row = $res->fetch_row();
	$stat = ($row[0]);
	
	$id_stat = $row[1];
	
	}
	
	if($row[1]!=3){
		$uptime = " --- ";
		$c_pw_pro = " --- ";
		$c_pw_con = " --- ";
		$tt_pw_pro = " --- ";
		$avg_pw_pro = " --- ";
	} else {
	
		// UPTIME
		$sql = "SELECT DATE_TIME FROM LOGS WHERE `ID_MODULE`=".$_POST['unique_id']." ORDER BY ID_LOG DESC LIMIT 1";
		$res = $con->query($sql);
		$row = $res->fetch_row();
	
		$date = getdate();
	
		$today = $date['year'].'-'.$date['mon'].'-'.$date['mday'].' '.$date['hours'].':'.$date['minutes'].':'.$date['seconds'];
	
		$diference = (strtotime($today,0) - strtotime($row[0],0));  
	
		$days = intval($diference/86400); // 24h * 60min * 60 sec = 86400;
	
		$diference = $diference%86400;
	
		$hours = intval($diference/3600);
	
		$diference = $diference%3600;
	
		$minutes = intval($diference/60) ;
	
		$diference = $diference%60;
	
		$seconds = intval($diference);
	
		$uptime = $days." days, ".$hours." h ".$minutes." m ".$seconds." s";
	
	
	
	// Image Select, only two ports in use.
	
	$ports = 2;
	$count = 0;
	$flag = false;
	
	while($count!=$ports){
		$count++;
		
		$sql = 'SELECT MODULES.UNIQUE_ID, MODULES.HUB_PORT, MODULES.NAME, STATUS.ID_STATUS AS ID_STATUS, STATUS.NAME AS STATUS 
				FROM `LOGS` , `STATUS` , MODULES 
				WHERE `STATUS`.ID_STATUS = `LOGS`.ID_STATUS 
				AND MODULES.HUB_PORT='.$count.'
				AND MODULES.UNIQUE_ID = LOGS.ID_MODULE
				ORDER BY `LOGS`.DATE_TIME DESC 
				LIMIT 1';		
		
		$res = $con->query($sql);
		
		$row = $res->fetch_assoc();
		
		$m_id[$count] = "";
		$m_name[$count] = "";
		$m_status[$count] = "";
		$m_id_status[$count] = "";
		
		if($row['ID_STATUS']!=2){
			$m_id[$row['HUB_PORT']] = $row['UNIQUE_ID'];
				//echo "<br>HUB_PORT: ".$row['HUB_PORT']."<br>ID: ".$m_id[$row['HUB_PORT']];
			$m_name[$row['HUB_PORT']] = $row['NAME'];
				//echo "<br>Name: ".$m_name[$row['HUB_PORT']];
			$m_status[$row['HUB_PORT']] = $row['STATUS'];
				//echo "<br>Status: ".$m_status[$row['HUB_PORT']]."<br>";
			$m_id_status[$row['HUB_PORT']] = $row['ID_STATUS'];
		}
	}
	}
	
	
	if(isset($_SESSION['priv']) && $_SESSION['priv']==1){
		$priv=$_SESSION['priv'];			
	} else {
		$priv=0;
	}
	
	echo '<DATA>'.
		 '<C_PW_PRO>'.$c_pw_pro.'</C_PW_PRO>'.
		 '<C_PW_CON>'.$c_pw_con.'</C_PW_CON>'.
		 '<TT_PW_PRO>'.$tt_pw_pro.'</TT_PW_PRO>'.
		 '<AVG_PW_PRO>'.$avg_pw_pro.'</AVG_PW_PRO>'.
		 '<UPTIME>'.$uptime.'</UPTIME>'.
		 '<STAT id_stat="'.$id_stat.'">'.$stat.'</STAT>'.
		 '<M1 id="'.$m_id[1].'" name="'.$m_name[1].'" status="'.$m_status[1].'" id_status="'.$m_id_status[1].'"></M1>'.
		 '<M2 id="'.$m_id[2].'" name="'.$m_name[2].'" status="'.$m_status[2].'" id_status="'.$m_id_status[2].'"></M2>'.
		 '<PRIV>'.$priv.'</PRIV>'.
		 '<DEV_ERROR>'.$_SESSION['error_device'].'</DEV_ERROR>'.
		 '</DATA>';
	
?>