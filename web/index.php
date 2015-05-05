<?php
	include "includes/header.php";
	include "includes/functions.inc.php";

	if (!empty($_SESSION))
		echo ('<script type="text/javascript">window.location = "home.php";</script>');

	//login attempt
	if (isset($_POST['id'])){
		$loggedIn = login($_POST);
		//redirect to home page on successful login
		if ($loggedIn)
			echo ('<script type="text/javascript">window.location = "home.php";</script>');
	}
?>

<form method="post" action="index.php">
	<label>Username:</label>
	<input type="text" name="id"><br>
	<label>Password</label>
	<input type="password" name="pw"><br>
	<input type="submit">
</form>
<?php if (!$loggedIn) {
	echo('<center><span style="color:red;"><b>Username or Password Incorrect</b></span></center>');
}
?>
