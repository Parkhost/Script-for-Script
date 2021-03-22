$URL = 'http://localhost:3000/input'
## let the api sanitize the data
$Apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select DisplayName, DisplayVersion, PSChildName
$json = [PSCustomObject][Ordered]@{ }

$more = @'
[
    {
        "ProductName":  "7-Zip 19.00 (x64)",
        "Version":  "19.00"
    },
    {
        "ProductName": "Microsoft Visual C++ 2013 Redistributable (x86) ",
        "Version":  "12.0.30501.0"
    },
    {
        "ProductName":  "Microsoft Exchange Server 2019",
        "Version":  "update"
    }
]
'@

$json = foreach ($App in $Apps) {
  if ($App.DisplayName -ne $null) {
    [ordered]@{ProductName = "$($App.DisplayName)"
      Version              = "$($App.DisplayVersion)"
    }
  }
  else {
    [ordered]@{ PSChild = "$($App.PSChildName)" 
      Version           = "$($App.DisplayVersion)"
    }
  }
}

$jsontest = @'
[
    {
        "ProductName": "Steam ",
        "Version":  "2.10.91.91"
    }
]
'@

$jsontestmessage = $jsontest

$jsonmessage = ConvertTo-Json $json -Depth 100


$parameters = @{
  "URI"         = $URL
  "Method"      = 'POST'
  "Body"        = $jsontestmessage
  "ContentType" = 'application/json'
}
 
Invoke-RestMethod @parameters
