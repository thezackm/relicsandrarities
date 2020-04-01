#region Top of Script

#requires -version 2

<#
.SYNOPSIS 
    Function to create New Relic Insights Dashboard

.DESCRIPTION 
    https://docs.newrelic.com/docs/insights/insights-api/manage-dashboards/insights-dashboard-api
    Requires a payload object modeled with the correct schema:  
        https://docs.newrelic.com/docs/insights/insights-api/manage-dashboards/insights-dashboard-api#schema

.EXAMPLE
    New-NRInsightsDashboard -AdminAPIKey "NRAA-123456789" -Payload $payloadObject

.NOTES
    Version:        1.0
    Author:         Zack Mutchler
    Creation Date:  04/01/2020
    Purpose/Change: Initial Script development.
#>

#endregion Top of Script

#####-----------------------------------------------------------------------------------------#####

#region Function Definition

Function New-NRInsightsDashboard{

    Param (

        [ Parameter ( Mandatory = $true ) ] [ string ] $AdminAPIKey,
        [ Parameter ( Mandatory = $true ) ] [ string ] $Payload

    )

# Set the target URI
$Uri = 'https://api.newrelic.com/v2/dashboards.json'

# Set the Authentication header
$Headers = @{ 'X-Api-Key' = $AdminAPIKey; 'Content-Type' = 'application/json' }

# POST to the REST API
Try{ 
    
    $Request = Invoke-WebRequest -Method Post -Uri $Uri -Headers $Headers -Body $Payload
    $Results = ( ( $Request ).Content | ConvertFrom-Json ).dashboard 

}
Catch{

    $Results = $_.Exception 

}

Return $Results

}

#endregion Function Definition

#####-----------------------------------------------------------------------------------------#####

#region Sample Execution 

# Sample Payload
$Payload = @"
 {
  "dashboard": {
    "metadata": { "version": 1 },
    "title": "PowerShell Function Sample",
    "icon":"heart",
    "visibility": "all",
    "editable": "editable_by_all",
    "widgets": [
      {
        "visualization": "markdown",
        "data": [
          {
            "source": "#This is a Markdown Widget\n\n ![Image](https://newrelic.com/assets/newrelic/source/PNG/NR_logo_Horizontal.png)"
          }
        ],
        "presentation": {
        "title": "",
        "notes": null
        },
        "layout": {
          "width": 1,
          "height": 2,
          "row": 1,
          "column": 1
        }
      }
    ]
  }
}
"@

# Uncomment below to try this out
#$AdminAPIKey = Read-Host -Prompt "What is your Admin API Key?"
#New-NRInsightsDashboard -AdminAPIKey $AdminAPIKey -Payload $Payload

#endregion Sample Execution
