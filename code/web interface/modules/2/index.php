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
				<tr style="display:none;">
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
           
           <script>
		   		getData(<?php echo '\''.$_GET['page'].'/\''; ?>,<?php echo $_GET['page']; ?>)
           </script>
          
          