<?php

	require_once("db_connect.php");

?>

        <script src="control.js" type="text/javascript" language="javascript"></script>
        <script>
			setInterval("getData(<?php echo '\''.$_GET['page'].'/\''; ?>,<?php echo $_GET['page']; ?>)", 1000);
		</script>
        
        	<div id="status">
			<table class="stat">
				<tr>
					<td class="identifier">Current power production</td><td id="c_pw_pro" class="value">2.0 kW</td>
				</tr>
				<tr>
					<td class="identifier">Current power consumption</td><td id="c_pw_con" class="value">1.8 kW</td>
				</tr>
				<tr>
					<td class="identifier">Total power production</td><td id="tt_pw_pro" class="value">135.15 kWh</td>
				</tr>
				<tr>
					<td class="identifier">Average power production</td><td id="avg_pw_pro" class="value">1.7 kWh</td>
				</tr>
				<tr>
					<td class="identifier">Uptime</td><td id="uptime" class="value">3 days 7 hours 34 minutes</td>
				</tr>
				<tr>
					<td class="identifier">Status</td><td id="stat" class="value">Running</td>
				</tr>
			</table>
			</div>
			
            <div class="modules">
            	
                <?php 
							$sql = 'SELECT `STATUS`.NAME, `STATUS`.ID_STATUS '.
								   'FROM `LOGS` , `STATUS` '.
								   'WHERE `STATUS`.ID_STATUS = `LOGS`.ID_STATUS AND `ID_MODULE`=0';
							$res = $con->query($sql);
							$row = $res->fetch_row();
							$stat = ($row[0]);
							
							if(isset($_SESSION['priv']) && $_SESSION['priv']==1){
								
								$actions = ' <tr>
							<td id="act_0" class="actions"><a href="#" onclick="sendCmd(0,\'s\')">Start</a> |
                   							<a href="#" onclick="sendCmd(0,\'p\')">Stop</a> </td>
						</tr>';
							
							} 
							
							
                ?>
              	  <table class="M">
						<tr>
							<td align="center" id="M0" class="mtitle">
                        		Hub
							</td>
						</tr>
						<tr>
							<td class="icon">
								<a href="?page=0" id="module0"><img src="0/header.png" alt="Energy Hub"/></a>
							</td>
						</tr>
						<tr>
							<td id="m0_stat" class="mstat">
                            	<?php echo $stat ?>
                            </td>
						</tr>
                       
                            	<?php echo $actions ?>
                           
				</table>
                
							
                    <?php
				
					$sql = 'SELECT MODULES.HUB_PORT, MODULES.UNIQUE_ID 
							FROM SENSORS 
							INNER JOIN MODULES ON SENSORS.ID_MODULE = MODULES.UNIQUE_ID 
							WHERE MODULES.ID_STATUS != 2 
							AND HUB_PORT!=11 
							ORDER BY HUB_PORT ASC';
							
					$res = $con->query($sql);
					
					$ports = 2;
					$count = 0;
					$flag = false;
					
						while($count!=$ports){
							$count++;
							
							if(!$flag){
								$row = $res->fetch_assoc();
							}
		
							if ($res->num_rows<=1){
								$flag = true;
							}
							
							
							if ($count==$row['HUB_PORT']){
								
							
							echo '<table class="M">';
							echo '<tr>
									<td align="center" id="M'.$row['HUB_PORT'].'"  class="mtitle">
											M'.$count.'
									</td>
								  </tr>';
							echo '<tr>
									<td class="icon">
										<a id="module'.$row['HUB_PORT'].'" ></a>
									</td>
								  </tr>';
							echo '<tr>
									<td id="m'.$row['HUB_PORT'].'_stat" class="mstat"></td>
								  </tr>';
							
							if(isset($_SESSION['priv']) && $_SESSION['priv']==1){
								
								$actions = '<a href="#" onclick="sendCmd('.$row['UNIQUE_ID'].',\'s\')">Start</a> |
                   							<a href="#" onclick="sendCmd('.$row['UNIQUE_ID'].',\'p\')">Stop</a>';
											
											echo '<tr>
									<td id="act_'.$row['HUB_PORT'].'" class="actions">
                            			'.$actions.'
                            		</td>
								</tr>';
							
							} 
							
							
						
							echo '</table>';
							
						} else {
							
							
							echo '<table class="M" >';
							echo '<tr>
									<td align="center" id="M'.$count.'" class="mtitle">
											M'.$count.'
									</td>
								  </tr>';
							echo '<tr>
									<td class="icon">
										<a id="module'.$count.'" ></a>
									</td>
								  </tr>';
							echo '<tr>
									<td id="m'.$count.'_stat" class="mstat"></td>
								  </tr>';
								  
							if(isset($_SESSION['priv']) && $_SESSION['priv']==1){
								
								echo '<tr>
									<td class="actions" id="act_'.$count.'">
                            		</td>
								</tr>';
							
							} 	  
						
							echo '</table>';
							
						}
					}
				
				?>
              
         	</div>
           
           <script>
				getData("",<?php echo $_GET['page']; ?>)
           </script>
          
          