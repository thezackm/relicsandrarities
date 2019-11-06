#region Top of Script

#requires -version 2

<#
.SYNOPSIS 
    Function to create New Relic Application Alert

.DESCRIPTION 
    https://rpm.newrelic.com/api/explore/alerts_conditions/create
    https://docs.newrelic.com/docs/alerts/rest-api-alerts/new-relic-alerts-rest-api/rest-api-calls-new-relic-alerts#conditions-create

.EXAMPLE
    New-NRApplicationAlert -AdminAPIKey '123456789ABCDEFGHIJ' -PolicyID '987654321' -AlertName 'testAlert' -Enabled true -Entities 9999999 `
    -Metric apdex -ConditionScope application -ViolationCloseTimer 24 -TermsDuration 120 -TermsOperator above -TermsPriority critical `
    -TermsThreshold 0.8 -TermsTimeFunction all -RunbookURL 'http://runbook.com'

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  11/05/2019
    Purpose/Change: Initial Script development.  
#>

#endregion

#####-----------------------------------------------------------------------------------------#####

# //TO-DO// Add logic to enable User Defined Metrics
#[ Parameter ( Mandatory = $false ) ] [ string ] $UserDefinedMetric,
#[ Parameter ( Mandatory = $false ) ] [ string ] $UserDefinedValueFunction

Function New-NRApplicationAlert {

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AdminAPIKey,
        [ Parameter ( Mandatory = $true ) ] [ string ] $PolicyID,
        [ Parameter ( Mandatory = $true ) ] [ string ] $AlertName,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'true', 'false' ) ] [ string ] $Enabled,
        [ Parameter ( Mandatory = $true ) ] [ array ] $Entities,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'apdex', 'error_percentage', 'response_time_web', 'response_time_background', 'throughput_web', 'throughput_background' ) ] [ string ] $Metric,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'application', 'instance' ) ] [ string ] $ConditionScope,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 1, 2, 4, 8, 12, 24 ) ] [ int ] $ViolationCloseTimer,
        [ Parameter ( Mandatory = $false ) ] [ string ] $RunbookURL,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 5, 10, 15, 30, 60, 120 ) ] [ int ] $TermsDuration,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'above', 'below', 'equal' ) ] [ string ] $TermsOperator,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'critical', 'warning' ) ] [ string ] $TermsPriority,
        [ Parameter ( Mandatory = $true ) ] [ ValidateRange( 0, [int]::MaxValue ) ] [ single ] $TermsThreshold,
        [ Parameter ( Mandatory = $true ) ] [ ValidateSet( 'all', 'any' ) ] [ string ] $TermsTimeFunction


    )

# Set the target URI
$uri = 'https://api.newrelic.com/v2/alerts_conditions/policies/' + $PolicyID + '.json'

# Set the Authentication header
$headers = @{ 'X-Api-Key' = $AdminAPIKey; 'Content-Type' = 'application/json' }

# Create a comma seperated string for the entities
$entitiesString = $Entities -join ','

# Create the alert condition payload
$body = @"
{
  "condition": {
    "type": "apm_app_metric",
    "name": "$AlertName",
    "enabled": $Enabled,
    "entities": [
      "$entitiesString"
    ],
    "metric": "$Metric",
    "condition_scope": "$ConditionScope",
    "violation_close_timer": "$ViolationCloseTimer",
    "runbook_url": "$RunbookURL",
    "terms": [
      {
        "duration": "$TermsDuration",
        "operator": "$TermsOperator",
        "priority": "$TermsPriority",
        "threshold": "$TermsThreshold",
        "time_function": "$TermsTimeFunction"
      }
    ]
  }
}
"@

# POST to the REST API
$results = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body

RETURN $results

}
