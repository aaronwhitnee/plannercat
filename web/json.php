<?php
include "../includes/functions.inc.php";

$JSON = "[ ";

$eID = intval($_GET['eventID']);
$con = sql_connect();

$query1 = mysqli_query($con, "SELECT * FROM form_field WHERE event_id=$eID;");
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
		while ($option = mysqli_fetch_array($query2)) {
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
?>
