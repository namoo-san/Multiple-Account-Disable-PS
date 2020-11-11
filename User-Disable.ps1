$WebhookURL = "WEBHOOK_URL"
$UserListPath = "FILEPATH"
​
Function Disable-Users{
    # 
    $i = 1
    $msgArray = @()
    $Encode = [Text.Encoding]::GetEncoding("UTF-8")
    $StreamRead = New-Object System.IO.StreamReader($UserListPath, $Encode)
    while (($Username = $StreamRead.ReadLine()) -ne $null) {
        # Using "Get-ADUser" command (Language : JPN)
        $Info = Get-ADUser -Filter { SamAccountName -eq $Username } -Properties *
        $msgArray += "名前 : " + [String]$Info["Name"]
        $msgArray += "GUID : " + [String]$Info["ObjectGUID"]
        $msgArray += "Description : " + [String]$Info["Description"]
        $msgArray += "SamAccountName : " + [String]$Info["SamAccountName"]
        Get-ADUser -Identity $Username | Disable-ADAccount
        $msgArray += "Account disabled."
        $i++
    }
    Slack_Post($msgArray)
}
​
function Slack_Post($Message) {
    # Slack post method
    $BodyText = $Message -join "`n"
    $payload = @{
        text = $BodyText;
    }
    $json = ConvertTo-Json $payload
    $body = [System.Text.Encoding]::UTF8.GetBytes($json)
    Invoke-RestMethod -Uri $WebhookURL -Method Post -Body $body
}
​
Disable-Users