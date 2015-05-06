<?php
include "../includes/functions.inc.php";

// Read incoming POST data
$handle = fopen("php://input", "rb");
$http_raw_post_data = '';
while ($handle && !feof($handle)) {
  $http_raw_post_data .= fread($handle, 8192);
}
fclose($handle);

// Convert raw POST data to JSON data
$request = json_decode($http_raw_post_data, true);
$response = array();

// Based on request type, generate an appropriate
// JSON response with fetched DB data
if (is_array($request)) {
  $requestType = $request["requestType"];
  $response["responseType"] = $requestType;

  // Logging in
  if ($requestType == "login") {
    $user_info = array(
      "id" => $request["request"]["userID"],
      "pw" => $request["request"]["password"]
    );
    $response["valid"] = login($user_info) ? 1 : 0;
    $response["status"] = "ok";
  }

  // Check in via scanning a QR Code ticket
  else if ($requestType == "checkinTicket") {
    // check in via ticket scan
    $response["status"] = "ok";
  }

  // Check in via form submission
  else if ($requestType == "checkinManual") {
    $response["status"] = "ok";

    $eventID = $request["request"]["eventID"];
    $response["formJsonString"] = event_form_json($eventID);
  }

  // Fetch all events managed by current user (userId from iOS)
  else if ($requestType == "events") {
    $response["status"] = "ok";
  }

  // Fetch all ticket receipts owned by current user
  else if ($requestType == "tickets") {
    $response["status"] = "ok";
  }

  // Invalid request type
  else {
    $response["status"] = "error";
  }
}

// Echo the JSON response back to the iOS app
$json_response = json_encode($response);
echo $json_response;

?>
