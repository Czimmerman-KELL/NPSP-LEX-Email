public class LFGController {
    @AuraEnabled
    public static List<npe5__Affiliation__c> findAffiliatedAccountsByEmail(String people, String mode) {
        People folks = (People) JSON.deserialize(people, People.Class);
        List<String> listEmails = new List<String>();
        String currUserEmail = UserInfo.getUserEmail();
        
        for(Recipient recp: folks.to)
            if(recp.email != currUserEmail)
            listEmails.add(recp.email);
        for(Recipient recp: folks.cc)
            if(recp.email != currUserEmail)
            listEmails.add(recp.email);
        if(folks.pFrom.email != currUserEmail)
            listEmails.add(folks.pFrom.email);
        
        List<npe5__Affiliation__c> affiliatedAccounts = [Select npe5__Organization__c, npe5__Organization__r.Name, 
                                                         npe5__Organization__r.RecordType.Name, npe5__Status__c,
                                                         npe5__Contact__c, npe5__Contact__r.Name, npe5__Role__c,
                                                         npe5__Primary__c 
                                                         From npe5__Affiliation__c 
                                                         Where (npe5__Contact__r.Email IN :listEmails
                                                                OR npe5__Contact__r.npe01__AlternateEmail__c IN :listEmails
                                                                OR npe5__Contact__r.npe01__WorkEmail__c IN :listEmails
                                                                OR npe5__Contact__r.npe01__HomeEmail__c IN :listEmails
                                                               )
                                                         ORDER BY npe5__Primary__c DESC
                                                        ];
        return affiliatedAccounts;
    }
    @AuraEnabled
    public static String linkEmailToAccount(List<String> accIds, String subject, String message, String people) {
        People folks = (People) JSON.deserialize(people, People.Class);
        String listEmails = '';
        for(Recipient recp: folks.to)
            listEmails = listEmails + recp.email + '; ';
        for(Recipient recp: folks.cc)
            listEmails = listEmails + recp.email + '; ';
        List<EmailMessage> listEM = new List<EmailMessage>();
        try {
            for(String accId: accIds) {
                listEM.add(new EmailMessage
                           (RelatedToId = accId,
                            HtmlBody = message,
                            Subject = subject,
                            FromAddress = folks.pfrom.email,
                            FromName = folks.pfrom.name,
                            ToAddress = listEmails));
            }
            insert listEM;
        }
        catch (Exception e) {
            return 'Error';
        }
        
        return 'Success';
    }
    
    public Class People {
        @AuraEnabled public List<LFGController.Recipient> to {get; set;}
        @AuraEnabled public LFGController.Recipient pfrom {get; set;}
        @AuraEnabled public List<LFGController.Recipient> cc {get; set;}
        @AuraEnabled public List<LFGController.Recipient> bcc {get; set;}
    }
    public Class Recipient {
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String full {get; set;}
    }
    /*@AuraEnabled
public static List<Account> getAffiliatedAccounts(String recipients, String mode) {
return null;
}*/
}