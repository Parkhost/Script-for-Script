$URL = 'http://localhost:3000/input'
# tried to do some PS sanitize before sending to api
$Apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select DisplayName, DisplayVersion, PSChildName
$json = [PSCustomObject][Ordered]@{}

$json = foreach($App in $Apps){
    if ($App.DisplayName -ne $null) {
        if ($App.DisplayName -contains "-") {
            #$App = 'Git version 2.25.1'
            $App.DisplayName = $App.DisplayName.split("-")[0]
        }
        if($App.DisplayName -match '(?=\d)'){
            $App.DisplayName = $App.displayName -split('(?=\d)',2)
            $App.DisplayName = $App.displayname[0]
        }
        if($App.PSChildName -like "{*" -and "*}") {
          [ordered]@{ProductName = "$($App.DisplayName.split("-")[0])"
          Version = "$($App.DisplayVersion)" }
        } else {
          [ordered]@{ProductName = "$($App.DisplayName.split("-")[0])"
          Version = "$($App.DisplayVersion)"
          PSChild = "$($App.PSChildName)" }
        }
          
    }
}

$jsontest = @'
[
    {
        "ProductName":  "Microsoft Visual C++ 2013 Redistributable (x86) ",
        "Version":  "12.0.30501.0"
    },
    {
        "ProductName":  "Microsoft Visual C++ 2013 x86 Additional Runtime ",
        "Version":  "12.0.21005"
    },
    {
        "ProductName":  "Microsoft Exchange Server 2019",
        "Version":  "update"
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



