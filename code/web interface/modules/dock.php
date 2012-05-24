<?php

	require_once("../includes/db_connect.php");

?>
		
		<a href="../"> <img src="../pic/dock_home.png" alt="home" /></a>
        <a href="?page=0"> <img src="../pic/dock_hub.png" alt="Hub Module" /></a>
        <a href="?page=2"> <img src="../pic/dock_photo.png" alt="Photovoltaics" /></a>
        <a href="?page=1"> <img src="../pic/dock_bat.png" alt="Battery" /></a>
        	
       	
         <?php if(isset($_SESSION['priv']) && $_SESSION['priv']>0){ ?>
            	<a href="#" onclick="logout('../')"> <img src="../pic/dock_key_open.png" alt="key_locked" name="0" id="lock" /> 	</a>
         <?php } else { ?>
           		<a href="#" onclick="login('../')"> <img src="../pic/dock_key_lock.png" alt="key_locked" name="1" id="lock" /> 	</a>
         <?php } ?>
       <!--
        <a href="?page=2"> <img src="../pic/dock_photo.png" alt="solar_module"/></a><img src="../pic/dot.png" alt="dot" />
        <a href="?page=1"> <img src="../pic/dock_bat.png" alt="battery_module"/></a><img src="../pic/dot.png" alt="dot" />
        <a href="#" onclick="alert('Not available on this web page version.')"><img src="../pic/dock_key_lock.png" alt="key_locked" id="lock" /></a>-->
		
<?php 
		/*       
        <div class="dot" id="dothub">
        	<img src="../pic/dot.png" alt="dot" />
        </div>
		*/
?>
        <div id="docknames">
        	<h3>EDE10 Team3</h3>
        	<p>Dennis Madsen<br/>
        	Theis Christensen<br/>
        	Paulo Miguel Fontes</p>
        </div>