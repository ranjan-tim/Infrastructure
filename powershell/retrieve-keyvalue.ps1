$json = @'
{
	"a": {
		"b": {
			"c": "d"
		}
	}
}
'@

function Get-FirstPropertyValue($value, $key) {
  $keys = $value.psobject.properties.Name
  if ($key -in $keys) {
    $value.$key
  } else {
    foreach ($iterkey in $keys) {
        if ($null -ne ($val = Get-FirstPropertyValue $value.$iterkey $key)) {
          return $val
        }
      }
  }
}

$objFromJson = $json | ConvertFrom-Json

$result = Get-FirstPropertyValue $objFromJson 'a' | ConvertTo-Json