<?php
error_reporting(E_ALL & ~E_NOTICE);
/*
	Main database handle
*/
function sql_connect(){return mysqli_connect('bpwebdesign.com', 'planner_cat', 'runnitt', 'planner_cat');}

/*
	login function
	Returns true if sucessful login
*/
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
?>
