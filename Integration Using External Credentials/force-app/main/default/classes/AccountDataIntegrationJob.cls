global class AccountDataIntegrationJob implements Schedulable {

    // Method to execute the scheduled job
    global void execute(SchedulableContext sc) {
        // Create an HTTP request and client to send the request
        HttpRequest httpRequest = new HttpRequest();
        Http httpClient = new Http();

        // SOQL query to fetch today's created accounts with 'Harshit' in their name
        // The query will search for Account records that were created today and contain 'Harshit' in their Name
        String soqlQuery = 'SELECT Name FROM Account WHERE CreatedDate = TODAY AND Name LIKE \'%Test%\'';
        
        // URL encode the query to make it safe for use in an HTTP request
        String encodedQuery = EncodingUtil.urlEncode(soqlQuery, 'UTF-8');

        // Define the endpoint URL for the API callout, using the named credential 'TestClientCred'
        // The endpoint connects to an external service using the TestClientCred named credential
        // The endpoint is configured to retrieve data based on the encoded SOQL query
        String endpointUrl = 'callout:External_API_Credentials/services/data/v56.0/queryAll/?q=' + encodedQuery;
        
        // Set the HTTP request method (GET) and headers
        httpRequest.setEndpoint(endpointUrl); // Set the request endpoint
        httpRequest.setMethod('GET'); // Define the HTTP method as GET for retrieving data
        httpRequest.setHeader('Content-Type', 'application/json'); // Set the content type to JSON

        try {
            // Sending the HTTP request to the endpoint
            HttpResponse httpResponse = httpClient.send(httpRequest);

            // Check if the response status code is 200 (successful)
            if (httpResponse.getStatusCode() == 200) {
                System.debug('Successful response: ' + httpResponse.getBody());
                
                // Parse the JSON response to extract the account data
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                List<Object> records = (List<Object>) responseMap.get('records');

                // Create a list to hold the new Account records
                List<Account> newAccounts = new List<Account>();

                // Iterate through the records from the API response and create Account objects
                for (Object record : records) {
                    // Extract each record from the response
                    Map<String, Object> accountRecord = (Map<String, Object>) record;
                    
                    // Create a new Account record and set the Name field
                    Account newAccount = new Account();
                    newAccount.Name = (String) accountRecord.get('Name'); // Set the Account name from the response
                    newAccounts.add(newAccount); // Add the new Account to the list
                }

                // Insert the new accounts into Salesforce if the list is not empty
                if (!newAccounts.isEmpty()) {
                    insert newAccounts; // Insert the accounts into the Salesforce database
                    System.debug('Inserted Accounts: ' + newAccounts); // Log the inserted accounts
                }
            } else {
                // If the response status code is not 200, log the error details
                System.debug('Error response: Status Code = ' + httpResponse.getStatusCode() + ', Status = ' + httpResponse.getStatus());
            }
        } catch (Exception e) {
            // Log any exceptions that occur during the HTTP request process
            System.debug('HTTP Request failed: ' + e.getMessage());
        }
    }
}