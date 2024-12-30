# Account Data Integration Job

This repository contains the `AccountDataIntegrationJob` Apex class and explains how to use **Named Credentials** and **External Credentials** for seamless integration between two Salesforce orgs.

---

## Purpose

The primary goal of this integration is to demonstrate how to securely and efficiently connect two Salesforce orgs to exchange data without hardcoding sensitive credentials.

1. **Source Org**: Hosts the **Connected App** to provide authentication and access tokens.  
2. **Target Org**: Uses **Named Credentials** and **External Credentials** to authenticate and communicate with the Source Org.

---

## Apex Class: `AccountDataIntegrationJob`

This class performs the following tasks:
1. Queries the Source Org for `Account` records created today with "Test" in their names.
2. Inserts the fetched accounts into the Target Org.

---

## Key Components

### 1. **Connected App** (Source Org)
A Connected App enables the Source Org to authenticate API requests from external systems.

#### Steps to Create:
1. Go to **Setup** → **App Manager** → **New Connected App**.
2. Fill in the required fields:
   - **Connected App Name**: `[Your_Connected_App_Name]`
   - **API Name**: `[Your_API_Name]`
   - **Contact Email**: your-email@example.com
3. Enable OAuth:
   - Check **Enable OAuth Settings**.
   - Set the **Callback URL** to any valid URL (e.g., `https://login.salesforce.com`).
   - Add OAuth Scopes:
     - `Full Access (full)`
     - `Perform requests on your behalf at any time (refresh_token, offline_access)`
4. Save the app and note the **Consumer Key** and **Consumer Secret**.

### 2. **External Credentials** (Target Org)
External Credentials manage authentication protocols securely in the Target Org.

#### Steps to Create:
1. Navigate to **Setup** → **External Credentials** → **New External Credential**.
2. Fill in the required fields:
   - **Label**: `[Your_External_Credentials_Name]`
   - **Authentication Protocol**: OAuth 2.0
   - **Authentication Flow Type**: `Client Credentials with Client Secret Flow`
3. Configure the OAuth flow with the Token Endpoint of the Source Org:
   - Example Token Endpoint: `https://login.salesforce.com/services/oauth2/token`
4. **Check the box** for **'Pass client credentials in request body'**.
5. Save the External Credentials.
6. Under **Principals**, use the Source Org's Connected App credentials:
   - **Consumer Key**
   - **Consumer Secret**

---

### 3. **Create Permission Set for External Credentials**

After saving the External Credentials, we need to create a Permission Set and assign it to the appropriate user to allow access to the External Credentials.

#### Steps to Create:
1. Navigate to **Setup** → **Permission Sets** → **New Permission Set**.
2. Fill in the required fields:
   - **Label**: `[Your_Permission_Set_Name]`
   - **Description**: (Optional, e.g., "Permission set to use External Credentials")
3. Under **App Permissions**, find and enable **External Data Source Access**.
4. Under **External Credential Principal Access**, click **Edit**.
5. From the **External Credential** dropdown, select the created External Credential (`[Your_External_Credentials_Name]`).
6. Save the changes to the Permission Set.

---

### 4. **Assign Permission Set to User**
Now, assign the created Permission Set to the appropriate user.

#### Steps to Assign:
1. Navigate to the user’s record page.
2. Under the **Permission Set Assignments** related list, click **Edit Assignments**.
3. Select the created Permission Set and click **Add**.
4. Save the changes.

The user now has access to the External Credentials and can use them in API callouts.

### 3. **Named Credentials** (Source Org)
Named Credentials store authentication settings, simplifying API callouts and secure communication.

#### Steps to Create:
1. Navigate to **Setup** → **Named Credentials** → **New Named Credential**.
2. Fill in the required fields:
   - **Label**: `[Your_Named_Credentials_Name]`
   - **Name**: `[Your_Named_Credentials_Name]`
   - **URL**: `https://[Your_Target_Org_URL]`
3. In the **External Credentials** section, select the **External Credential** you created earlier from the dropdown.
4. **Select the following checkboxes**:
   - **Generate Authorization Header**: This ensures that the authorization header is automatically generated for the API request.
   - **Allow Formulas in HTTP Header**: Allows the use of formulas within the HTTP headers for dynamic value generation.
   - **Allow Formulas in HTTP Body**: Allows the use of formulas within the HTTP body for dynamic value generation.
5. Save the Named Credential.

---

## How the Integration Works

1. The `AccountDataIntegrationJob` class uses the **Named Credentials** (`[Your_Named_Credentials_Name]`) for secure API callouts to the Source Org.
2. The Named Credentials internally use the **External Credentials** (`[Your_External_Credentials_Name]`) to handle authentication via OAuth 2.0.
3. The HTTP GET request fetches Account data from the Source Org using a SOQL query.
4. The Target Org processes the response and inserts the fetched accounts.

---

## Steps to Deploy and Run the Integration

### In the Source Org:
1. Create a **Connected App** as described above.
2. Ensure it is active and accessible for API calls.

### In the Target Org:
1. Set up **External Credentials** and **Named Credentials**.
2. Deploy the `AccountDataIntegrationJob` class.
3. Schedule the class via the Salesforce Scheduler:
   - Navigate to **Setup** → **Apex Scheduler** → Schedule the job.

---

## Benefits of Named and External Credentials

- **Security**: No hardcoded credentials in Apex.
- **Ease of Use**: Simplifies API callouts with a single reference to Named Credentials.
- **Scalability**: Supports seamless integration for various external systems.