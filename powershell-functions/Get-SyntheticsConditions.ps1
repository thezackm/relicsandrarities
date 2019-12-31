#region Top of Script

#requires -version 2

<#
.SYNOPSIS
    Function to list New Relic Synthetics Alert Conditions

.DESCRIPTION
    https://rpm.newrelic.com/api/explore/alerts_synthetics_conditions/list
    https://docs.newrelic.com/docs/alerts/rest-api-alerts/new-relic-alerts-rest-api/rest-api-calls-new-relic-alerts#synthetics-conditions-list

.EXAMPLE
    Get-SyntheticsConditions -AccountAPIKey '1a2b3c4d5e6f' -PolicyID '123456'
        List all Synthetics Conditions for the Alert Policy

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  12/31/2019
    Purpose/Change: Initial Script development
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

Function Get-SyntheticsConditions {

    Param (

        [ Parameter (Mandatory = $true ) ] [ string ] $AccountAPIKey,
        [ Parameter (Mandatory = $true ) ] [ string ] $PolicyID

    )

# Set the target URI with query string
$getSyntheticsConditionsUri = "https://api.newrelic.com/v2/alerts_synthetics_conditions.json?policy_id=" + $PolicyID

# Set the headers to pass
$headers = @{ 'X-Api-Key' = $AccountAPIKey; 'Content-Type' = 'application/json' }

# Query the API
$results = ( Invoke-RestMethod -Method Get -Uri $getSyntheticsConditionsUri -Headers $headers ).synthetics_conditions

RETURN $results

}
