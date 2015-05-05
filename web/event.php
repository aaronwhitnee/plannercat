<?php 
	include "includes/header.php";
	include "includes/functions.inc.php";

	$eID = intval($_GET['eventID']);
	$con = sql_connect();
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

				else if ($row['field_type'] == 'drop_down'){
					echo " <input type='text' name='" . $fieldID . "'><br>";
				}
			}
		?>
		<input type='submit' value='Sign Up!'>
	</form>
</center>