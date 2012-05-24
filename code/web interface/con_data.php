<?php

	require_once("includes/db_connect.php");
	
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
	
	
	
	echo '<DATA>'.
		 '<M1 id="'.$m_id[1].'" name="'.$m_name[1].'" status="'.$m_status[1].'" id_status="'.$m_id_status[1].'"></M1>'.
		 '<M2 id="'.$m_id[2].'" name="'.$m_name[2].'" status="'.$m_status[2].'" id_status="'.$m_id_status[2].'"></M2>'.
		 '</DATA>';
	
?>