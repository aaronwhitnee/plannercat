<?php
	include "includes/header.php";
	include "includes/functions.inc.php";

	if (!empty($_SESSION))
		echo ('<script type="text/javascript">window.location = "home.php";</script>');

	//login attempt
	if (isset($_POST['email'])){
		$loggedIn = login($_POST);
		//redirect to home page on successful login
		if ($loggedIn) {
			echo ('<script type="text/javascript">window.location = "home.php";</script>');
		}
	}
?>

<form method="post" action="index.php">
	<label>Email:</label>
	<input type="text" name="email"><br>
	<label>Password</label>
	<input type="password" name="pw"><br>
	<input type="submit">
</form>
<?php if (isset($_POST['email']) && !$loggedIn) {
	echo('<center><span style="color:red;"><b>Username or Password Incorrect</b></span></center>');
}
?>
