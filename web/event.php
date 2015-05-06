<?php 
	include "includes/header.php";
	include "includes/functions.inc.php";
	$con = sql_connect();

	if (!empty($_POST)){
		mysqli_query($con, "INSERT INTO user(firstName, lastName, hasAccount) VALUES ('Guest', 'User', 0);");
		$uID = mysqli_insert_id($con);	
		$eID = $_POST['eventID'];
		mysqli_query($con, "INSERT INTO receipt(user_id, event_id, quantity) VALUES ($uID, $eID, 1);");
		$i=0;
		foreach ($_POST as $name => $val){
			if ($i == count($_POST) - 1)
				break;
			mysqli_query($con, "INSERT INTO user_form_values(form_field_id, user_id, user_value) VALUES($name, $uID, '$val');");
			$i++;
		}
		$jsonStr = '[{"userID":' . $uID . ',"eventID":' . $eID . ',"name":"Guest User"}]';
		$qrStr = "https://chart.googleapis.com/chart?chs=350x350&cht=qr&chl=" . $jsonStr . "&choe=UTF-8";
		echo("<img src='" . $qrStr . "'>");
	}

	else{

		$eID = intval($_GET['eventID']);
		$query = mysqli_query($con, "SELECT * FROM event WHERE id=$eID;");
		$result = mysqli_fetch_array($query);
?>

<center>
	<h3><?php echo $result['event_title']; ?></h3>
	<b>Date:</b> <?php echo $result['start_date']; ?><br>
	<b>Venue:</b> <?php echo $result['venue']; ?><br>
	<b>Description:</b><br><?php echo $result['description']; ?><br>
	<br>
	<b>Sign Up!</b><br>
	<form action='event.php' method='post'>
		<?php
			$query1 = mysqli_query($con, "SELECT * FROM form_field WHERE event_id=$eID;");
			while ($row=mysqli_fetch_array($query1)){
				$fieldID = $row['id'];
				echo $row['question'];
				if ($row['field_type'] == 'radio'){
					echo ": <br>";
					$query2 = mysqli_query($con, 
						"SELECT * FROM field_list_values WHERE form_field_id=$fieldID");
					while ($option = mysqli_fetch_array($query2)){
						echo "
							<input type='radio' name='" . $fieldID . "' value='" .
							$option['list_value'] . "'>" . $option['list_value'] . "<br>
							";
					}
				}

				else if ($row['field_type'] == 'text'){
					echo " <input type='text' name='" . $fieldID . "'><br>";
				}
			}
		?>
		<input type='hidden' value= <?php echo "'" . $eID . "'"; ?> name='eventID'> 
		<input type='submit' value='Sign Up!'>
	</form>
</center>

<?php } ?>