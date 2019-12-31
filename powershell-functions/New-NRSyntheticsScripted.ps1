# region Top of Script

# requires -version 2

<#
.SYNOPSIS
    Function to create New Relic Synthetics SCRIPT_BROWSER and SCRIPT_API checks

.DESCRIPTION
    https://docs.newrelic.com/docs/apis/synthetics-rest-api/monitor-examples/manage-synthetics-monitors-rest-api#scripted-api-monitors-api

.EXAMPLE
    SCRIPT_BROWSER test with 5 min interval in 2 locations
        New-NRSyntheticsScripted -AdminAPIKey '123456789ABCDEFG' -CheckType 'Scripted Browser' -CheckName 'SCRIPT_BROWSER-Testing' `
        -CheckFrequency 5 -CheckLocations 'AWS_US_EAST_1', 'AWS_US_EAST_2' -CheckStatus enabled -SLAThreshold 7.0 `
        -ScriptFile 'C:\path\to\script.js'

    SCRIPT_API test with 12 hr interval in 1 location
        New-NRSyntheticsScripted -AdminAPIKey '123456789ABCDEFG' -CheckType 'API Test' -CheckName 'SCRIPT_API-Testing' `
        -CheckFrequency 720 -CheckLocations 'AWS_US_EAST_1' -CheckStatus muted -SLAThreshold 4.0 `
        -ScriptFile 'C:\path\to\script.js'

.NOTES
    Version:        1.0
    Author:         Rishav Dhar
    Creation Date:  10 DEC 2019
    Purpose/Change: Initial Script development.
#>

# endregion

#####-----------------------------------------------------------------------------------------#####

Function New-NRSyntheticsScripted {

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AdminAPIKey,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet ( 'Scripted Browser', 'API Test' ) ] [ string ] $CheckType,
        [ Parameter ( Mandatory = $true ) ] [ string ] $CheckName,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 1, 5, 10, 15, 30, 60, 360, 720, 1440 ) ] [ int ] $CheckFrequency,
        [ Parameter ( Mandatory = $true ) ] [ array ] $CheckLocations,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet ( 'enabled', 'muted', 'disabled' ) ] [ string ] $CheckStatus,
        [ Parameter ( Mandatory = $true ) ] [ double ] $SLAThreshold,
        [ Parameter ( Mandatory = $true ) ] [ string ] $ScriptFile

    )

# Set the target URI
$uri = 'https://synthetics.newrelic.com/synthetics/api/v3/monitors/'

# Set the Authentication header
$headers = @{ 'X-Api-Key' = $AdminAPIKey; 'Accept' = 'application/json'; 'Content-Type' = 'application/json' }

# Create a comma separated string for the locations
$locationsString = $CheckLocations -join '", "'

# Setup the Check Type
$type = Switch( $CheckType ) {

    'Scripted Browser' { 'script_browser' }
    'API Test' { 'script_api' }

}

# Create the Synthetics Check payload
$body = ConvertTo-Json @{

    name = $CheckName
    type = $type
    frequency = $CheckFrequency
    locations = @($locationsString)
    status = $CheckStatus
    slaThreshold = $SLAThreshold

}

# POST to the REST API to create a new monitor
$requestMonitor = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $body

# Grab the UUID of the created monitor
$monitorID = $requestMonitor.Headers.Location.Split('/')[-1]

# Convert script file to BASE64 encoding
$scriptPayload = ConvertTo-Json @{"scriptText" = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Encoding UTF8 -Raw $ScriptFile)))}

# PUT script via the REST API
$requestScript = Invoke-WebRequest -Method Put -Uri $uri$monitorID/script -Headers $headers -Body $scriptPayload

RETURN $monitorID

}
