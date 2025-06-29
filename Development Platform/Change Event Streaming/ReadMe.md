# SQL Server 2025 Change Event Streaming Setup

Login to the Azure port to create the required Azure resources for Change Event Streaming (CES) in SQL Server 2025. This includes an Event Hub and a Storage Account, which will be used to store the change events and manage consumer checkpoints.

## Create Event Hub

Create and configure an Azure Event Hub to receive change events from SQL Server 2025.

- Create a resource > Event Hubs
  - Resource Group: `ces-demos-rg`
  - Namespace Name: `ces-namespace`
  - Pricing Tier: **Basic**
  - Create and go to resource

- Create Event Hub
  - Click `+ Event Hub`
  - Name: `ces-hub`

- Create Event Hub Policy
  - Click `ces-hub`
  - Go to Settings > Shared Access Policies
  - Click `+ Add`
  - Policy name: `ces-policy`
  - Check `Manage` (this also includes `Send` and `Listen`)
  - Click `Create`

## Create Storage Account

Create an Azure Storage Account to manage consumer checkpoints.

- Create a resource > Storage Account
  - Resource Group: `ces-demos-rg`
  - Storage account name: `sql2025ces`
  - Primary service: `Azure Blob Storage or Azure Data Lake Storage Gen2`
  - Redundancy: `Locally redundant storage (LRS)`
  - Create and go to resource

- Create Blob Container
  - Go to Data Storage > Containers
  - Click `+ Add container`
  - Name: `ces-blob`
  - Click `Create`
  - Go to Security + Networking > Access Keys
  - Show and copy the connection string (then paste to Notepad)


## Generate the SAS Token

Generate a Shared Access Signature (SAS) token for the Event Hub to allow SQL Server to generate change events, and client applications to consume them.

- Edit Generate-SasToken.ps1

  ```powershell
  $resourceGroupName = "ces-demos-rg"    # Replace with your Resource Group name
  $namespaceName = "ces-namespace"       # Replace with your Event Hub Namespace   name
  $eventHubName = "ces-hub"              # Replace with your Event Hubs instance   name
  $policyName = "ces-policy"             # Replace with the policy name
  ```

- Run PowerShell as administrator

- Change to the directory where Generate-SasToken.ps1 is located. For example:

  ```powershell
  cd "C:\Projects\Sleek\sql2025-workshop-private\Development Platform\Change Event Streaming" 
  ```

- These modules only need to be installed once:

  ```powershell
  Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
  Install-Module -Name Az.EventHub -Scope CurrentUser -Force
  ```
    
- If you are already running an older version of the Az modules, they can be updated with:

  ```powershell
  Update-Module -Name Az.*
  ```

- Enable script execution for the current PowerShell session:

  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

  When prompted, type `Y` to confirm.

- Execute Generate-SasToken.ps1

  ```powershell
  .\Generate-SasToken.ps1
  ```

  When prompted, sign in with your Azure account.
	 
  If you have multiple subscriptions, select the subscription that contains the Event Hub Namespace.

- Copy the generated SAS token to Notepad
  ```powershell
  SharedAccessSignature sr=...&skn=ces-policy
  ```

## References

https://learn.microsoft.com/en-us/sql/relational-databases/track-changes/change-event-streaming/configure?view=sql-server-ver17
