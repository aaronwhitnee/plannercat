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

  // Logging in
  if ($requestType == "login") {
    $response["status"] = "ok";
    $email = $request["request"]["email"];
    $password = $request["request"]["password"];

    $user_info = array(
      "email" => $email,
      "pw" => $password
    );

    $response["valid"] = login($user_info) ? 1 : 0;
    $response["userID"] = get_user_ID($email);
  }

  // Check in via scanning a QR Code ticket
  else if ($requestType == "checkinTicket") {
    $response["status"] = "ok";

    $eventID = $request["request"]["eventID"];
    $userID = $request["request"]["userID"];
    $firstName = $request["request"]["firstName"];
    $lastName = $request["request"]["lastName"];

    $checkin_status = checkin_user($userID, $eventID);
    $response["checkin_status"] = $checkin_status;
  }

  // Registration and checkin via form submission
  else if ($requestType == "register") {
    $response["status"] = "ok";

    $eventID = $requst["requst"]["eventID"];
    $userID = $request["request"]["userID"];

  }

  // Fetch the registration form JSON for a given event
  else if ($requestType == "eventForm") {
    $response["status"] = "ok";

    $eventID = $request["request"]["eventID"];
    $response["formJsonString"] = event_form_json($eventID);
  }

  // Fetch all events managed by given user
  else if ($requestType == "events") {
    $response["status"] = "ok";

    $userID = $request["request"]["userID"];
    $response["eventsJsonString"] = get_user_events($userID);
  }

  // Fetch all guests registered for a given event
  else if ($requestType == "guests") {
    $response["status"] = "ok";

    $eventID = $request["request"]["eventID"];
    $response["guestsJsonString"] = get_event_guests($eventID);
    $response["eventID"] = $eventID;
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
