# Environment Setup
Given that this is currently a one-time process, there is no ARM tempate provided for this.  It is possible to do this in the future. 

## Creating Azure Automation Account
1. Navigate to Azure Portal
2. In the top search for `Automation Account`
3. Click the `+` to create a new account
4. Name should be something relevant Ex: `Outside-Policy-Checker`
5. Select a subscription for this resource to live in
6. Select a resource group for this to live in
7. Select a location
8. Ensure that `Create Azure Run As account` is `Yes`
9. Click `Create`

This will create an Azure Automation Account and grants it `Contributor` on the subscription.  This needs to be changed to `Global Reader` at the Root Group.  (Global Reader might be too much, but in the interest of time we will use this)



## Configuring Automation Account Modules
Once the account is created, we must configure it.
1. Navigate to the Automation Account Resource
2. Under `Modules Gallery` search for `Accounts`.  This should display `Az.Accounts`.  Select it.  
3.  Select the `Import` option.  This operation takes approximately 5 minutes.  (You will see an Azure Notification that says it's complete, but under the hood it takes extra time)
4.  Once `Az.Accounts` is imported, repeat steps 2 and 3 for `Az.ResourceGraph`

# Next Steps
Now that an Automation Account is created, we need to author a PowerShell Runbook per query that we require.  