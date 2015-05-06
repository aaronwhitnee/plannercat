<?php
include "../includes/functions.inc.php";

// Read incoming data
$handle = fopen("php://input", "rb");
$http_raw_post_data = '';
while ($handle && !feof($handle)) {
  $http_raw_post_data .= fread($handle, 8192);
}
fclose($handle);

// Convert raw data to JSON data
$request = json_decode($http_raw_post_data, true);
$response = array();

// Based on request type, generate an appropriate JSON response with DB data
if (isarray($request)) {
  $requestType = $request["reqType"];
  $response["resType"] = $requestType;

  if ($requestType == "login") {
    // log in
    $user_info = array(
      "id" => $post_data["id"],
      "pw" => $post_data["password"]
    );
    $response["status"] = "ok";
    $response["valid"] = login($user_info) ? 1 : 0;
    $response["code"] = 0;
  }

  else if ($requestType == "checkinTicket") {
    // check in via ticket scan
  }

  else if ($requestType == "checkinManual") {
    // check in via form submission
  }

  else {
    // invalid request type
  }
}

// Echo a JSON response back to iOS app
$json_response = json_encode($response);
echo $json_response;

?>
