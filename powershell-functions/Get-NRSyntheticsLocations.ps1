#region Top of Script

#requires -version 2

<#
.SYNOPSIS 
    Function to query valid New Relic Synthetics Locations

.DESCRIPTION 
    https://docs.newrelic.com/docs/apis/synthetics-rest-api/monitor-examples/manage-synthetics-monitors-rest-api#list-locations

.EXAMPLE
    Get-NRSyntheticsLocations -AdminAPIKey $AdminAPIKey

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  11/05/2019
    Purpose/Change: Initial Script development.  
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

Function Get-NRSyntheticsLocations {

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AdminAPIKey

    )

# Set the target URI
$uri = 'https://synthetics.newrelic.com/synthetics/api/v1/locations'

# Set the Authentication header
$headers = @{ 'X-Api-Key' = $AdminAPIKey }

# Query the REST API
$results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

RETURN $results

}
