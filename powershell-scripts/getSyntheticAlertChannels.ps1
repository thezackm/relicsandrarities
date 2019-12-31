#region Top of Script

#requires -version 2

<#
.SYNOPSIS
	Queries the New Relic API to audit alert policies and their associated Synthetics alert conditions and notification channels

.DESCRIPTION
    Requires the Account API Key for the target account

.NOTES
	Version:		1.0
	Author:			Zack Mutchler
	Creation Date:	12/31/2019
    Purpose/Change:	Initial script development.
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

#region Script Parameters

Param(

    [ Parameter( Mandatory = $true ) ] [ValidateNotNullOrEmpty() ] [ string ] $AccountAPIKey

)

#endregion Script Parameters

#####-----------------------------------------------------------------------------------------#####

#region Functions

# Create a function to enumerate all Alert Policies for an account
Function Get-NRAlertPolicies {

    Param (

        [ Parameter (Mandatory = $true ) ] [ string ] $AccountAPIKey,
        [ Parameter (Mandatory = $false ) ] [ string ] $FilterName,
        [ Parameter (Mandatory = $false ) ] [ ValidateSet( 'true', 'false' ) ] [ string ] $ExactMatch = 'false'

    )

# Set the target URI if no FilterName is provided
If ( ( !$FilterName ) ) {

$getPoliciesUri = "https://api.newrelic.com/v2/alerts_policies.json"

}

# Set the target URI with provided filter
Else {

$getPoliciesUri = "https://api.newrelic.com/v2/alerts_policies.json/?filter[name]=" + $FilterName + '&filter[exact_match]=' + $ExactMatch

}

# Set the headers to pass
$headers = @{ 'X-Api-Key' = $AccountAPIKey; 'Content-Type' = 'application/json' }

# Query the API
$results = ( Invoke-RestMethod -Method Get -Uri $getPoliciesUri -Headers $headers ).policies

RETURN $results

}

# Create a function to enumerate all Synthetics Alert Conditions for an account
Function Get-NRSyntheticsConditions {

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

# Create a function to enumerate all Notification Channels for an account
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

#endregion Functions

#####-----------------------------------------------------------------------------------------#####

#region Execution

# Get a list of all Alert Policies
$policies = Get-NRAlertPolicies -AccountAPIKey $AccountAPIKey

# Get a list of all Notification Channels
$channels = Get-NRNotificationChannels -AccountAPIKey $AccountAPIKey

# Build an empty array to hold our Alert Policy IDs that have Synthetics Alert Conditions
$syntheticsPolicies = @()

# Iterate through each policy and isolate the ones with Synthetics Alert Conditions
foreach ( $p in $policies ) {

    $query = Get-SyntheticsConditions -AccountAPIKey $AccountAPIKey -PolicyID $p.id

    foreach ( $q in $query ) {

            Write-Host "Synthetics Conditions found in Alert Policy: $( $p.name )" -ForegroundColor Cyan
            $syntheticsPolicies += $p.id

    }

}

# Build an empty array to hold our results
$results = @()

# Iterate through the Notification Channels to see if any are assigned to a Policy with Synthetics Alert Conditions
foreach ( $c in $channels ) {

    foreach( $l in $c.links.policy_ids ) {

        # Build a PSObject to add to our results
        $item = New-Object -TypeName psobject

        if( $l -in $syntheticsPolicies ) {

            # Grab the alert policy name for readability in the results
            $pName = ( $policies | Where-Object {  $_.id -eq $l } ).name
            Write-Host "Notification Channel "$( $c.name )" is assigned to Alert Policy: $( $pName )" -ForegroundColor Yellow
            
            # Fill the PSObject
            $item | Add-Member -MemberType NoteProperty -Name 'AlertPolicyID' -Value $l
            $item | Add-Member -MemberType NoteProperty -Name 'AlertPolicyName' -Value $pName
            $item | Add-Member -MemberType NoteProperty -Name 'ChannelID' -Value $c.id
            $item | Add-Member -MemberType NoteProperty -Name 'ChannelName' -Value $c.name
            $item | Add-Member -MemberType NoteProperty -Name 'ChannelType' -Value $c.type
          
            # Add the PSObject to our results array
            $results += $item

        }

    }

}

#endregion Execution

# Play that beautiful bean footage...
$results | Format-Table -AutoSize
