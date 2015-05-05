<?php

include "../includes/functions.inc.php";

// Read incoming data
$handle = fopen("php://input", "rb");
$http_raw_post_data = '';
while ($handle && !feof($handle)) {
  $change += 1;
  $http_raw_post_data .= fread($handle, 8192);
}
fclose($handle);

// Convert raw data to JSON data
$post_data = json_decode($http_raw_post_data, true);

// Check if JSON is valid
$response = array();
if (is_array($post_data)) {
  $user_cred = array("id" => $post_data["id"], "pw" => $post_data["password"]);
  $valid = login($user_cred) ? 1 : 0;

  $response = array(
    "status" => "ok",
    "code" => 0,
    "valid" => $valid,
    // "original_request" => $post_data
    );
}
else {
  $response = array(
    "status" => "error",
    "code" => -1,
    "valid" => 0,
    // "original_request" => $post_data
    );
}

// Echo a JSON response back to iOS app
$json = json_encode($response);
echo $json;

?>
