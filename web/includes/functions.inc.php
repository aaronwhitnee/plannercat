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
function login($post){
	//grabbing relavent post info
	$id = $post['id']; $pw = $post['pw'];

	//getting user from database
	$con = sql_connect();
	$query = mysqli_query($con, "SELECT * FROM user WHERE id = '$id';");
	$result = mysqli_fetch_array($query);
	$usr = $result['id'];

	//invalid user
	if (!$result){
		// echo('<center><span style="color:red;"><b>Invalid User ID</b></span></center>');
		mysqli_close($con);
		return false;
	}

	//successful login
	else if (strcmp(md5($pw),trim($result['password']))==0) {
		session_regenerate_id();
			$_SESSION['username']=$usr;
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
?>
