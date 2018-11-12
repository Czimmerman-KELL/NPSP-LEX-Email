@isTest
private class LFGControllerTest {
    @testSetup static void createData() {
        Contact cont = new Contact (FirstName = 'FName', LastName = 'LName',
                                   Email = 'testEmail@email.com');
        insert cont;
        Account acc = new Account(Name = 'Test Organization');
        insert acc;
        
        npe5__Affiliation__c aff = new npe5__Affiliation__c (npe5__Contact__c = cont.Id,
                                                            npe5__Organization__c = acc.Id,
                                                            npe5__Status__c = 'Current');
        insert aff;
    }
    
    @isTest static void testData() {
        Contact cont = [Select Id, FirstName, LastName, Email From Contact Limit 1];
        
        LFGController.Recipient recp = new LFGController.Recipient();
        recp.name = cont.FirstName + ' ' + cont.LastName;
        recp.full = cont.FirstName + ' ' + cont.LastName;
        recp.Email = cont.Email;
            
        LFGController.People people = new LFGController.People();
		people.to = new List<LFGController.Recipient>();
        people.cc = new List<LFGController.Recipient>();
        people.bcc = new List<LFGController.Recipient>();
        people.to.add(recp);
        people.pFrom = recp;
        people.cc.add(recp);
        people.bcc.add(recp);
            
        List<npe5__Affiliation__c> listAffReturned = LFGController.findAffiliatedAccountsByEmail(JSON.serialize(people), 'Read');
        System.assertEquals(listAffReturned.size(), 1);
        List<String> listAccIds = new List<String> {listAffReturned[0].npe5__Organization__c};
            
        String result = LFGController.linkEmailToAccount(listAccIds, 'NPSP Email Test', 'Body', JSON.serialize(people));
        System.assertEquals(result, 'Success');
        
        List<EmailMessage> listEM = [Select Id From EmailMessage Where Subject = 'NPSP Email Test'];
        System.assertEquals(listEM.size(), 1);
        
    }
}