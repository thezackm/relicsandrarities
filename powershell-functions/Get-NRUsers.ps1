#region Top of Script

#requires -version 2

<#
.SYNOPSIS 
    Function to list New Relic users

.DESCRIPTION 
    https://rpm.newrelic.com/api/explore/users/list
    https://docs.newrelic.com/docs/apis/rest-api-v2/account-examples-v2/listing-users-your-account

.EXAMPLE
    Get-NRUsers -AccountAPIKey '123456789ABCDEFGHIJ' 
        List all users for the account

    Get-NRUsers -AccountAPIKey '123456789ABCDEFGHIJ' -UserID 123, 456, 789
        List users matching IDs from the provided array
    
    Get-NRUsers -AccountAPIKey '123456789ABCDEFGHIJ' -UserEmail first.last
        List users matching the provided email pattern (the API will automatically add wildcards to your string)

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  11/05/2019
    Purpose/Change: Initial Script development.  
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

Function Get-NRUsers {

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AccountAPIKey,
        [ Parameter ( Mandatory = $false ) ] [ array ] $UserID,
        [ Parameter ( Mandatory = $false ) ] [ string ] $UserEmail

    )

# Set the target URI
$rootUri = "https://api.newrelic.com/v2/users.json"

# Set the Authentication header
$header = @{ 'X-Api-Key' = $AccountAPIKey; 'Content-Type' = 'application/json' }

# UserID and UserEmail filter
if( $UserID -and $UserEmail ) {

    # Pick one or the other
    Write-Warning -Message "Please choose either ID or Email filter, not both. Exiting..."
    Exit 1

}

# UserID filter
if( $UserID -and ( !( $UserEmail ) ) ) {

    # Set the URL with filter params
    $filterUri = $rootUri + '?filter[ids]=' + ( $UserID -join ',' )

}

# UserEmail filter
if( ( !( $UserID ) ) -and $UserEmail ) {

    # Set the URL with filter params
    $filterUri = $rootUri + '?filter[email]=' + ( $UserEmail )

}

# No filters
if( ( !( $UserID ) ) -and ( !( $UserEmail ) ) ) {

    # Set the URL with filter params
    $filterUri = $rootUri

}

# Query the API
Write-Host "Querying against: $( $filterUri )" -ForegroundColor Cyan
$results = ( Invoke-RestMethod -Method Get -Uri $filterUri -Headers $header ).users 

RETURN $results

}

