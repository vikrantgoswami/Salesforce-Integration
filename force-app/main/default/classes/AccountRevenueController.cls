public class AccountRevenueController {

    public static Integer getTotalRevenueByAccountId(Id accountId) {
        Integer totalRevenue = 0;
        
        try{
            Account account = [SELECT Id, Name, AnnualRevenue, (SELECT Id, AnnualRevenue FROM ChildAccounts) FROM Account WHERE Id = :accountId];
            if(account.AnnualRevenue != null) {
                System.debug('Account Name '+account.Name+ ' And Revenue is '+account.AnnualRevenue);
                totalRevenue += (Integer)account.AnnualRevenue;
            }
            
            //List<Account> listOfChildAccounts = [SELECT Id, ParentId, AnnualRevenue FROM Account WHERE ParentId = :accountId];
            List<Account> listOfChildAccounts = account.ChildAccounts;
            for(Account childAccount : listOfChildAccounts) {
                totalRevenue += (Integer)getTotalRevenueByAccountId(childAccount.Id);
            }
        }
        catch(Exception exc){
            System.debug('Exception '+exc.getMessage());
        }
        return totalRevenue;
    }
    
    public static Integer getTotalRevenueByAccountIdIterative(Id accountId) {
    Integer totalRevenue = 0;

    // Set to track all accounts to be processed
    Set<Id> accountsToProcess = new Set<Id>();
    accountsToProcess.add(accountId); // Start with the given accountId
    
    // Map to store accounts already processed
    Set<Id> processedAccounts = new Set<Id>();
	Integer i = 0;
    while (!accountsToProcess.isEmpty()) {
        System.debug(++i);
        // Query for accounts at this level (parent and all current children)
        List<Account> accountList = [
            SELECT Id, ParentId, AnnualRevenue 
            FROM Account 
            WHERE Id IN :accountsToProcess
        ];

        // Clear accountsToProcess to be refilled with new children
        accountsToProcess.clear();

        // Loop through the result of the query
        for (Account acc : accountList) {
            // Add revenue to totalRevenue if available and account is not already processed
            if (acc.AnnualRevenue != null && !processedAccounts.contains(acc.Id)) {
                totalRevenue += (Integer) acc.AnnualRevenue;
            }
            
            // Mark this account as processed
            processedAccounts.add(acc.Id);
            
            // Add child accounts to process in the next iteration
            accountsToProcess.add(acc.Id);  // Add current account
        }

        // Query child accounts of the newly found accounts
        List<Account> childAccounts = [
            SELECT Id, ParentId, AnnualRevenue 
            FROM Account 
            WHERE ParentId IN :processedAccounts
        ];
        
        // Add these child accounts to accountsToProcess for the next iteration
        for (Account childAcc : childAccounts) {
            if (!processedAccounts.contains(childAcc.Id)) {
                accountsToProcess.add(childAcc.Id);  // Add the child account to be processed
            }
        }
    }

    return totalRevenue;
}

}