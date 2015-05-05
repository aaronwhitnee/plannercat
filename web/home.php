<?php 
	include "includes/header.php"; 

	if (empty($_SESSION))
		echo ('<script type="text/javascript">window.location = "index.php";</script>');

	if (isset($_SESSION['admin'])){
		echo "
			<h2>Admin Home Page</h2>
			<a href='create.php'>Create an event</a>
		";
	}

	else{
		echo "user view";
	}
?>
