#region Top of Script

#requires -version 2

<#
.SYNOPSIS
    Function to list New Relic Alert Notification Channels

.DESCRIPTION
    https://rpm.newrelic.com/api/explore/alerts_channels/list
    https://docs.newrelic.com/docs/alerts/rest-api-alerts/new-relic-alerts-rest-api/rest-api-calls-new-relic-alerts#channels-list

.EXAMPLE
    Get-NRNotificationChannels -AccountAPIKey '1a2b3c4d5e6f'
        List all Notification Channels for an Account

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  12/31/2019
    Purpose/Change: Initial Script development
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

Function Get-NRNotificationChannels {

Param(

    [ Parameter ( Mandatory = $true ) ] [ string ] $AccountAPIKey

)

# Set the target URI
$uri = 'https://api.newrelic.com/v2/alerts_channels.json'

# Set the headers to pass
$headers = @{
	'X-Api-Key' = $AccountAPIKey
}

# Query the API
$results = ( Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ContentType 'application/json' ).channels

RETURN $results

}
