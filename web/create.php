<?php
	include "includes/header.php";
	include "includes/functions.inc.php";
	if (!isset($_SESSION['admin']))
		echo ('<script type="text/javascript">window.location = "home.php";</script>');

	if (!empty($_POST)){
		createEvent();
	}
	else{
?>
<h2>Create an event</h2>

<form action="create.php" method="post">
	<!-- START EVENT META INFO -->
	<h3>Event Details</h3>
	<label>Name: </label>
	<input type='text' name='name'><br>
	<label>Time: </label>
	<input type='text' name='time'><br>
	<label>Venue: </label>
	<input type='text' name='venue'><br>
	<label>Description: </label>
	<textarea name="desc"></textarea><br><br>
	<!-- END EVENT META INFO -->

	<!-- START CUSTOM FIELDS -->
	<b>User Input Fields</b><br>
	<select id="inType">
		<option>Text Field</option>
		<option>Drop Down</option>
		<option>Radio Button</option>
	</select>
	<div id="options" style="display:none;">
		Number of options:
		<input type="number" id="numOptions" style="width:40px;">
	</div>
	<button type='button' id='addItem'>Add New Item</button>

	<div id="textFields">
	</div>

	<div id="radioFields">
	</div>

	<div id="dropFields">
	</div>

	<!-- END CUSTOM FIELDS -->
	<br><br>
	<input type="hidden" name="textCount" id="textCount" value="0">
	<input type="hidden" name="dropCount" id="dropCount" value="0">
	<input type="hidden" name="radioCount" id="radioCount" value="0">

	<input type="submit" value="Create Event">
</form>


<script>
	var txtLength = 0;
	var radioLength = 0;
	var dropLength = 0;

	$("#addItem").click(function () {
		if ($("#inType option:selected").text() == "Text Field"){
			txtLength++;
			var titleNm = "textNew" + txtLength.toString();
			$("#textFields").append("<br>Add New Field:<br>\
		 		Field Name: <input type='text' name='" + titleNm + "'> <br>");
		  $("#textCount").val(txtLength);
		}
		else if ($("#inType option:selected").text() == "Drop Down"){
			dropLength++;
			var titleNm = "dropNew" + dropLength.toString();
			var fieldCount = "dropCount" + dropLength.toString();
			$("#dropFields").append("<br>Add New Drop Down:<br>\
				<input type='hidden' value='" + document.getElementById('numOptions').value + "' name='" + fieldCount + "'>\
		 		Drop Down Title: <input type='text' name='" + titleNm + "'> <br>");
			for (var i=0; i<document.getElementById('numOptions').value; i++) {
				$("#dropFields").append("Option Value: <input type='text' name='" + titleNm + "optionNum" + i.toString() + "'> <br>");
			};
		  $("#dropCount").val(dropLength);
		}
		else if ($("#inType option:selected").text() == "Radio Button"){
			radioLength++;
			var fieldCount = "radioCount" + radioLength.toString();
			var titleNm = "radioNew" + radioLength.toString();
			$("#radioFields").append("<br>Add New Radio Button:<br>\
				<input type='hidden' value='" + document.getElementById('numOptions').value + "' name='" + fieldCount + "'>\
		 		Radio Button Title: <input type='text' name='" + titleNm + "'> <br>");
			for (var i=0; i<document.getElementById('numOptions').value; i++) {
				$("#radioFields").append("Option Value: <input type='text' name='" + titleNm + "optionNum" + i.toString() + "'> <br>");
			};
		  $("#radioCount").val(radioLength);
		}
  });

	$("#inType").change(function(){
		if ($("#inType option:selected").text() == "Drop Down" || $("#inType option:selected").text() == "Radio Button"){
			$("#options").show();
		}
		else{
			$("#options").hide();
		}
	});
</script>

<?php
	} // end else

	function createEvent(){
		$con = sql_connect();

		//insert meta data for event
		$title=$_POST['name']; $time=$_POST['time'];$venue=$_POST['venue'];$desc=$_POST['desc'];
		mysqli_query($con, "INSERT INTO event(event_title, start_date, venue, description)
			VALUES ('$title', '$time', '$venue', '$desc');");
		$query = mysqli_query($con, "SELECT id FROM event WHERE event_title='$title' AND start_date='$time';");
		$result = mysqli_fetch_array($query);
		$eID = $result['id'];
		$userID = $_SESSION['userID'];
		mysqli_query($con, "INSERT INTO events_managers(event_id, user_id)
			VALUES ('$eID', '$userID')");

		/* START DYNAMIC FIELD INSERTION */
		//text fields
		for ($i=0;$i<intval($_POST['textCount']);$i++){
			$question = $_POST["textNew" . strval($i + 1)];
			mysqli_query($con, "INSERT INTO form_field(question, event_id, field_type)
				VALUES ('$question', $eID, 'text');");
		}

		//radio buttons
		for ($i=0;$i<intval($_POST['radioCount']);$i++){
			$question = $_POST["radioNew" . strval($i + 1)];
			mysqli_query($con, "INSERT INTO form_field(question, event_id, field_type)
				VALUES ('$question', $eID, 'radio');");

			//get ID for radio
			$query = mysqli_query($con, "SELECT id FROM form_field WHERE question='$question' AND event_id=$eID;");
			$result = mysqli_fetch_array($query);
			$fieldID = $result['id'];

			//add options to radio field
			for ($j=0;$j<intval($_POST['radioCount' . strval($i + 1)]);$j++){
				$value = $_POST["radioNew" . strval($i + 1) . "optionNum" . strval($j)];
				mysqli_query($con, "INSERT INTO field_list_values(form_field_id, list_value) VALUES($fieldID, '$value');");
			}
		}

		//drop down
		for ($i=0;$i<intval($_POST['dropCount']);$i++){
			$question = $_POST["dropNew" . strval($i + 1)];
			mysqli_query($con, "INSERT INTO form_field(question, event_id, field_type)
				VALUES ('$question', $eID, 'drop');");

			//get ID for drop
			$query = mysqli_query($con, "SELECT id FROM form_field WHERE question='$question' AND event_id=$eID;");
			$result = mysqli_fetch_array($query);
			$fieldID = $result['id'];

			//add options to drop field
			for ($j=0;$j<intval($_POST['dropCount' . strval($i + 1)]);$j++){
				$value = $_POST["dropNew" . strval($i + 1) . "optionNum" . strval($j)];
				mysqli_query($con, "INSERT INTO field_list_values(form_field_id, list_value) VALUES($fieldID, '$value');");
			}
		}
		/* END DYNAMIC FIELD INSERTION */
	}
?>
