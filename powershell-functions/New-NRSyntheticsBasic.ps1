#region Top of Script

#requires -version 2

<#
.SYNOPSIS 
    Function to create New Relic Synthetics PING and SIMPLE BROWSER checks

.DESCRIPTION 
    https://docs.newrelic.com/docs/apis/synthetics-rest-api/monitor-examples/manage-synthetics-monitors-rest-api#create-monitor

.EXAMPLE

    PING test with 1min inerval, 2 locations, and Validation String
        New-NRSyntheticsBasic -AdminAPIKey '123456789ABCDEFG' -CheckType Ping -CheckName 'PING-Testing' -CheckFrequency 1 `
        -CheckURL 'https://developer.newrelic.com/' -CheckLocations 'AWS_US_EAST_2', 'AWS_US_EAST_1' -CheckStatus enabled `
        -SLAThreshold 1.0 -ValidationString 'Build apps'
        
    SIMPLE BROWSER test with 1min interval and 2 locations
        New-NRSyntheticsBasic -AdminAPIKey '123456789ABCDEFG' -CheckType 'Simple Browser' -CheckName 'SIMPLE-Testing' `
        -CheckFrequency 1 -CheckURL 'https://developer.newrelic.com/' -CheckLocations 'AWS_US_EAST_2', 'AWS_US_EAST_1' `
        -CheckStatus enabled -SLAThreshold 4.0

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  11/05/2019
    Purpose/Change: Initial Script development.
    
    Version:        1.1
    Author:         Zack Mutchler
    Creation Date:  11/05/2019
    Purpose/Change: Updated to grab UUID from results. 
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

Function New-NRSyntheticsBasic {

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AdminAPIKey,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet ( 'Ping', 'Simple Browser' ) ] [ string ] $CheckType,
        [ Parameter ( Mandatory = $true ) ] [ string ] $CheckName,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 1, 5, 10, 15, 30, 60, 360, 720, 1440 ) ] [ int ] $CheckFrequency,
        [ Parameter ( Mandatory = $true ) ] [ string ] $CheckURL,
        [ Parameter ( Mandatory = $true ) ] [ array ] $CheckLocations,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet ( 'enabled', 'muted', 'disabled' ) ] [ string ] $CheckStatus,
        [ Parameter ( Mandatory = $true ) ] [ double ] $SLAThreshold,
        [ Parameter ( Mandatory = $false ) ] [ string ] $ValidationString,
        [ Parameter ( Mandatory = $false ) ] [ ValidateSet ( 'true', 'false' ) ] [ string ] $VerifySSL,
        [ Parameter ( Mandatory = $false ) ] [ ValidateSet ( 'true', 'false' ) ] [ string ] $BypassHEADRequest,
        [ Parameter ( Mandatory = $false ) ] [ ValidateSet ( 'true', 'false' ) ] [ string ] $TreatRedirectAsFailure

    )

# Set the target URI
$uri = 'https://synthetics.newrelic.com/synthetics/api/v3/monitors'

# Set the Authentication header
$headers = @{ 'X-Api-Key' = $AdminAPIKey; 'Content-Type' = 'application/json' }

# Create a comma seperated string for the locations
$locationsString = $CheckLocations -join '", "'

# Setup the Check Type
$type = Switch( $CheckType ) {

    'Ping' { 'simple' }
    'Simple Browser' { 'browser' }

}

# Create the Synthetics Check payload
$body = @"
{
	"name": "$CheckName",
	"frequency": $CheckFrequency,
	"uri": "$CheckURL",
	"locations": [
		"$locationsString"
	],
	"type": "$type",
	"status": "$CheckStatus",
	"slaThreshold": "$SLAThreshold",
    "options": {
        "validationString": "$ValidationString",
        "verifySSL": "$VerifySSL",
        "bypassHEADRequest": "$BypassHEADRequest",
        "treatRedirectAsFailure": "$TreatRedirectAsFailure"
    }
}
"@

# POST to the REST API
$request = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $body

# Grab the UUID of the created check
$results = $request.Headers["Location"].Split("/")[-1]

RETURN $results

}
