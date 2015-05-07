<?php
error_reporting(E_ALL & ~E_NOTICE);
/************
	Main database handle
*************/
function sql_connect(){return mysqli_connect('bpwebdesign.com', 'planner_cat', 'runnitt', 'planner_cat');}

/*************
	login function
	Returns true if sucessful login
*************/
function login($user_info) {
	//grabbing relavent post info
	$email = $user_info['email'];
	$pw = $user_info['pw'];

	//getting user from database
	$con = sql_connect();
	$query = mysqli_query($con, "SELECT * FROM user WHERE email = '$email';");
	$result = mysqli_fetch_array($query);
	$userID = $result['id'];

	//invalid user
	if (!$result){
		// echo('<center><span style="color:red;"><b>Invalid User ID</b></span></center>');
		mysqli_close($con);
		return false;
	}

	//successful login
	else if (strcmp(md5($pw),trim($result['password']))==0) {
		session_regenerate_id();
			$_SESSION['userID'] = $userID;
			if ($result['admin'] == 1)
				$_SESSION['admin'] = true;
		session_write_close();
		mysqli_close($con);
		return true;
	}

	//invalid password
	// echo('<center><span style="color:red;"><b>Invalid Password</b></span></center>');
	mysqli_close($con);
	return false;
}

/*************
	Helper function that returns
	a user's unique ID using their email address
*************/
function get_user_id($email) {
	//getting user from database
	$db = sql_connect();
	$query = mysqli_query($db, "SELECT * FROM user WHERE email = '$email'");
	$result = mysqli_fetch_array($query);
	$userID = $result['id'];

	return $userID;
}

/*************
	Generates the JSON string
	for a dynamic event form
*************/
function event_form_json($eventID) {
	$JSON = "[ ";

	$con = sql_connect();

	$query1 = mysqli_query($con, "SELECT * FROM form_field WHERE event_id=$eventID;");
	$first = True;
	while ($row=mysqli_fetch_array($query1)){
		if(!$first)
			$JSON .=', ';
		$first = False;
		$fieldID = $row['id'];
		$JSON .= '{"key": "' . $row['question'] . '"';
		if ($row['field_type'] == 'radio'){
			$JSON .= ', "options": [';
			$query2 = mysqli_query($con, "SELECT * FROM field_list_values WHERE form_field_id=$fieldID");
			$first2 = True;
			while ($option = mysqli_fetch_array($query2)){
				if(!$first2)
					$JSON .= ', ';
				$first2 = False;
				$JSON .= '"' . $option['list_value'] . '"';
			}
			$JSON .= ']';
		}

		else if ($row['field_type'] == 'text'){
			$JSON .= ', "type": "text"';
		}
		$JSON .= '}';
	}

	$JSON .= " ]";

	return $JSON;
}

/*************
	Generates a JSON string for
	all events managed by a given user
*************/
function get_user_events($userID) {
	$db = sql_connect();

	$query = mysqli_query($db,
		"SELECT * FROM event AS E
		JOIN events_managers AS EM ON ( EM.event_id = E.id )
		WHERE EM.user_id = $userID");

	$events = array();
	while ($row = mysqli_fetch_assoc($query)) {
		$events[] = $row;
	}

	$JSON = json_encode($events);
	return $JSON;
}


?>
