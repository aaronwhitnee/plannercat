<?php 
	include "includes/header.php";
	include "includes/functions.inc.php";
	$con = sql_connect();	

	if (isset($_GET['userID'])){
		$eID = $_GET['eventID'];
		$uID = $_GET['userID'];
		$query = mysqli_query($con, "SELECT user_id, question, user_value, form_field_id, form_field.id 
			FROM user_form_values JOIN form_field ON form_field.id = form_field_id 
			WHERE user_id=$uID;");
	}

	else if (isset($_GET['eventID'])){
		$eID = $_GET['eventID'];
		$query = mysqli_query($con, "SELECT user_id, firstName, lastName, user.id, checkin, event_id FROM receipt 
		JOIN user ON user.id=user_id WHERE checkin=0 AND event_id=$eID;");
		echo "Users that didn't show:<br>";
		while ($row = mysqli_fetch_array($query)){
			echo "<a href='stats.php?userID=" . $row['user_id'] . "&eventID=" . $eID . "'>" . $row['firstName'] 
			. " " . $row['lastName'] . "</a><br>";
		}

	}
	else{
		$query = mysqli_query($con, "SELECT * from event");
		while ($row = mysqli_fetch_array($query))
			echo "<a href='stats.php?eventID=" . $row['id'] . "'>" . $row['event_title'] . "</a><br>";
	}
	
?>