@isTest
public class SQX_CaseTriggerHandler_Test {
    
    private static final String PermissionSet_Label='Case Admin';
    private static final String PermissionSet_Name='Case_Admin';
    private static final String CASE_TYPE_PROBLEM='Problem';
    private static final String CASE_STATUS='Escalated';
    private static final String CASE_TYPE_OTHER='other';
    
    //Creating Test Data 
    
    @TestSetup
    static void makeTestData(){
        
        Profile profile=[SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User user = new User(Alias = 'testUser', Email='testUser@gmail.com', 
            EmailEncodingKey='UTF-8', LastName='Test User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc@testorg.com');
        Insert user;
        
        
        System.runAs(returnCurrentUser())
        {
            PermissionSet permission_set=new PermissionSet();
            Permission_set.Label=PermissionSet_Label;
            Permission_set.Name=PermissionSet_Name;
            Insert Permission_set;
            
            
            
            PermissionSetAssignment permissionSet_Assignment = new PermissionSetAssignment();  
            PermissionSet_Assignment.AssigneeId = returnCurrentUser().Id;
            PermissionSet_Assignment.PermissionSetId = permission_set.id;
            Insert permissionSet_Assignment;
            
            
        }
    }
    
    @isTest
    static void insertIfTypeProblem()
    {  
        //Given 
        //data from makeTestData()
        
        //When 
        System.runAs(returnCurrentUser())
        {
            Test.startTest();
            
			Insert createCase(CASE_TYPE_PROBLEM);
            
            Test.stopTest();
            
            //Then 
            case cs=[SELECT id,Priority,CaseNumber FROM case]; 
            SQX_Nonconformance__c nonconformance=[SELECT id,priority__c,QMS_Reference_Number__c,Title__c FROM SQX_Nonconformance__c limit 1];
            
            system.assertEquals(cs.Priority, nonconformance.Priority__c);
            system.assertEquals(cs.CaseNumber, nonconformance.QMS_Reference_Number__c);
            
        }
    }
    
    @isTest
    static void insertIfTypeIsNotProblem()
    {  
        //Given 
        //data from makeTestData()
        
        //When 
        System.runAs(returnCurrentUser())
        {
            Test.startTest();
            
            Insert createCase(CASE_TYPE_OTHER);
            
            Test.stopTest();
  
            //Then
            case cs=[SELECT id,SQX_NC_Reference__c FROM case];
            system.assertEquals(null,cs.SQX_NC_Reference__c);
            
        }
    }
    
    @isTest
    static void updateIfTypeIsProblem()
    { 
        //Given 
        //data from makeTestData()
        
        //When
        System.runAs(returnCurrentUser())
        {
            Test.startTest();
            
            case cs= createCase(CASE_TYPE_OTHER);
            Insert cs;
            
            cs.Type=CASE_TYPE_PROBLEM;
            Update cs;
            test.stopTest();
            
            //Then
            
            Case casee=[SELECT id,Priority,CaseNumber,status FROM Case];
            SQX_Nonconformance__c nonconformance=[SELECT id,priority__c,QMS_Reference_Number__c,Title__c FROM SQX_Nonconformance__c limit 1];
            
            system.assertEquals(casee.Priority, nonconformance.Priority__c);
            system.assertEquals(casee.CaseNumber, nonconformance.QMS_Reference_Number__c);
            system.assertEquals(casee.Status,CASE_STATUS);
            
        }
    }
    
    @isTest
    static void updateIfTypeIsOtherThanProblem()
    {  
        //Given 
        //data from makeTestData()
        
        //When
        System.runAs(returnCurrentUser())
        {
            Test.startTest();
            Case cs= createCase(CASE_TYPE_PROBLEM);
            Insert cs;
            cs.Priority='High';
            Update cs;   
            Test.stopTest();
            
            //Then
            Case casee=[SELECT id,Priority,CaseNumber,status FROM Case];
            system.assertEquals('New',casee.Status);
            
        }
    }
    
    @isTest
    static void updateIfPermissionSetIsNotAssigned(){
        //Given 
        //data from makeTestData()
        
        //When
        User user=[SELECT Id FROM user where Email='testUser@gmail.com'];
        
        system.runAs(user){
        	Test.startTest();
			 Case cs=createCase(CASE_TYPE_OTHER);
			 Insert  cs;
             
             cs.Type=CASE_TYPE_PROBLEM;
             Update cs;
            Test.stopTest();
            
            //Then
            
            Case casee=[SELECT Id,Status FROM Case];
            List<SQX_Nonconformance__c> nonconformances=[SELECT Id FROM SQX_Nonconformance__c];
            
            System.assertEquals('New', casee.Status);
            System.assertEquals(0, nonconformances.size());    
        }      
    }
    
    private static Case createCase(string caseType){
        return (new case(Status='New',Origin='Phone',Type=caseType,Priority='Medium',Description='test case'));
    }
    
    private static User returnCurrentUser(){
        return ([SELECT id FROM User where Id=:userinfo.getUserId()]);
    }
}