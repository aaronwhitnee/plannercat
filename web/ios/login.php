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

$response = array(
  "status" => "error",
  "code" => 0,
  "valid" => 0
);

// Check if JSON is valid
if (is_array($post_data)) {
  $user_cred = array("id" => $post_data["id"], "pw" => $post_data["password"]);
  $valid = login($user_cred) ? 1 : 0;
  $response["status"] = "ok";
  $response["code"] = -1;
  $response["valid"] = $valid;
}
else {
  $response["status"] = "error";
  $response["code"] = -1;
  $response["valid"] = 0;
}

// Echo a JSON response back to iOS app
$json = json_encode($response);
echo $json;

?>
