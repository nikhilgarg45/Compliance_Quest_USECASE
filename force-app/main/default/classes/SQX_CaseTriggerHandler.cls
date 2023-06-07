public class SQX_CaseTriggerHandler {
    private static final String CASE_TYPE='Problem';
    private static final String CASE_STATUS_ESCALATED='Escalated';
    private static final String CASE_STATUS_NEW='NEW';
    private static Map<Id,SQX_Nonconformance__c> nonconformances=new Map<Id,SQX_Nonconformance__c>();
    private static List<case> updatesCases=new List<case>();
    private static List<PermissionSetAssignment> PermissionSets=[SELECT Id,PermissionSet.name FROM PermissionSetAssignment WHERE  PermissionSet.Name='Case_Admin' AND AssigneeId=:userInfo.getUserId()];
    
    
    // Create Nonconformance and update case if Criteria Matched during Insert Context
    public static void checkandCreateNonconformance(List<Case>cases){
        
        try{
            for(Case cs:cases){
                if(cs.Type==CASE_TYPE){
                    createNonconformance(cs);    
                }    
            }
            if(nonconformances.values().size()>0){
                Insert nonconformances.values();
                
                for(Case cs:cases)
                {
                    updatesCases.add(createCase(cs,CASE_STATUS_NEW));  
                }
                if(!updatesCases.isEmpty()){
                    Update updatesCases;
                }
                
            }
        }
        
        catch(Exception ex){
            // Should Log instead of Debugging
            system.debug(ex.getMessage()+' at update'+ex.getLineNumber());
        }
    }
    
    // Create Nonconformance and update case if Criteria Matched during Update Context
    public static void updateCaseIfUserHasPermissionSet(List<Case> cases){
        try{
            for(Case cs:cases)
            {
                
                if(PermissionSets.size()>0 && cs.SQX_NC_Reference__c==null && cs.type==CASE_TYPE)
                {
                    createNonconformance(cs);
                }
            }
            if(nonconformances.values().size()>0)
            {
                Insert nonconformances.values();
                for(Case cs:cases)
                {
                    updatesCases.add(createCase(cs,CASE_STATUS_ESCALATED));
                }
                
                if(!updatesCases.isEmpty()){
                    update updatesCases;
                }
            }
        }catch(Exception ex){
            // Should Log instead of Debugging
            system.debug(ex.getMessage()+' at update'+ex.getLineNumber());
        }
    }
    
    //Create NonConformance Record
    private static void createNonconformance(Case cs){
        SQX_Nonconformance__c nonconformance=new SQX_Nonconformance__c();
        nonconformance.Priority__c=cs.Priority;
        nonconformance.Title__c= cs.Subject;
        nonconformance.Description__c= cs.Description;
        nonconformance.QMS_Reference_Number__c =cs.CaseNumber;
        nonconformances.put(cs.Id,nonconformance);
    }
    
    //Creating case object
    private static Case createCase(Case cs,String status){
        return new Case(Id=cs.Id,SQX_NC_Reference__c=nonconformances.get(cs.Id).Id,Status=status);
    }
    
}
