## Set output location, to be used by the convert_to_csv statements
$loc = "<output_folder_location>"

## load the VC DLL's needed for this script
Add-Type -Path "<install_location_of_VC>\VisualCronAPI.dll"
Add-Type -Path "<install_location_of_VC>\VisualCron.dll"

## create a connection to a VC server
## update the conn.address to the server you want to connect to
$conn = New-Object VisualCronAPI.Connection
$conn.Address = $env:COMPUTERNAME
$conn.UseADLogon = $true
$conn.ConnectionType = 'remote'
$client = New-Object VisualCronAPI.Client
$session = $client.Connect($conn)

## get server details
$session_details =  $session |
                    Select @{l="ServerName";e={$conn.Address}},ServerId, Version, IP, Port,  @{l="Server_ON";e={$session.on}}

## get all job details. 
## Are used for task and trigger details as well
$job_data = $session.Jobs.GetAll()
$job_details = $job_data | Select Group, @{N='JobName';E={$_.Name}}, @{N='JobID';E={$_.Id}}, CreatedBy, ModifiedBy

## get all task details
$task_details = foreach ($job in $Job_data)
                    {
                    $job.tasks | Select @{l="Group";e={$Job.Group}}, @{l="JobName";e={$Job.Name }}, JobId, @{N='TaskName';E={$_.Name}}, @{N='TaskID';E={$_.Id}}, TaskType
                    }

## get all trigger details
$trigger_details = foreach ($job in $Job_data)
                    {
                    $job.triggers | Select @{l="Group";e={$Job.Group}}, @{l="JobName";e={$Job.Name }}, JobId, Description, @{N='TriggerID';E={$_.Id}}, TriggerType
                    }

## get all user details 
$user_data = $session.Permissions.GetAllUsers()
$user_details = foreach ($user in $user_data)
                    {
                     $group_data = $session.Permissions.GetGroup($user.Groups)
                     $user | 
                     Select Id, 
                     @{l="FullName";e={$session.Permissions.GetFullUserName($user.Id)}}, 
                     @{l="UserName";e={$session.Permissions.GetUserName($user.Id)}}, 
                     @{l="Email";e={$session.Permissions.GetUserEmail($user.Id)}}, 
                     @{l="UserGroup";e={$group_data.name}}, 
                     @{l="UserGroupID";e={$group_data.Id}}, 
                     IsADUser, 
                     IsADGroup,
                     Active
                    }

## Save output
$session_details | ConvertTo-Csv -Delimiter "|" -NoTypeInformation | Select-Object -Skip 1 |  % {$_ -replace '"','' -replace "'",'' -replace "{",'(' -replace "}",')'}   | Set-Content -Path "$loc\server_details.txt"
$job_details | ConvertTo-Csv -Delimiter "|" -NoTypeInformation | Select-Object -Skip 1 |  % {$_ -replace '"','' -replace "'",'' -replace "{",'(' -replace "}",')'}   | Set-Content -Path "$loc\job_details.txt"
$task_details | ConvertTo-Csv -Delimiter "|" -NoTypeInformation | Select-Object -Skip 1 |  % {$_ -replace '"','' -replace "'",'' -replace "{",'(' -replace "}",')'}  | Set-Content -Path "$loc\task_details.txt"
$trigger_details | ConvertTo-Csv -Delimiter "|" -NoTypeInformation | Select-Object -Skip 1 |  % {$_ -replace '"','' -replace "'",'' -replace "{",'(' -replace "}",')'}  | Set-Content -Path "$loc\trigger_details.txt"
$user_details | ConvertTo-Csv -Delimiter "|" -NoTypeInformation | Select-Object -Skip 1 |  % {$_ -replace '"','' -replace "'",'' -replace "{",'(' -replace "}",')'}  | Set-Content -Path "$loc\user_details.txt"
