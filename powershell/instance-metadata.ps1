$IP = "http://169.254.169.254"
$Endpoint = $IP + "/metadata/instance/"

$uri = $Endpoint + "?api-version=2021-02-01"
$response = Invoke-RestMethod -Method GET -NoProxy -Uri $uri -Headers @{"Metadata"="True"} | ConvertTo-Json -Depth 64
$response


# query compute metadata

$IP = "http://169.254.169.254"
$Endpoint = $IP + "/metadata/instance/compute/sku"

$uri = $Endpoint + "?api-version=2021-02-01&format=text"
$response = Invoke-RestMethod -Method GET -NoProxy -Uri $uri -Headers @{"Metadata"="True"} 
$response


# query network metadata

$IP = "http://169.254.169.254"
$Endpoint = $IP + "/metadata/instance/network/interface/"

$uri = $Endpoint + "?api-version=2021-02-01&format=json"
$response = Invoke-RestMethod -Method GET -NoProxy -Uri $uri -Headers @{"Metadata"="True"} | ConvertTo-Json -Depth 64
$response
