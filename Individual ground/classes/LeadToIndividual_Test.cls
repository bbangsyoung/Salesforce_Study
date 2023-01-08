@IsTest
public with sharing class LeadToIndividual_Test {

    @TestVisible
    private void setup() {
    }

    @IsTest //Lead Create - 1. 일반생성
    public static void createLeadTest() {
        List<Lead> leadList = new List<Lead>();
        Lead lead = new Lead(Company = 'companyName', LastName = 'Test', Email = 'ddd@naver.com');
        leadList.add(lead);

        //Insert Data
        Test.startTest();
        insert leadList;
        Test.stopTest();

        List<Individual> indieList = [SELECT Id FROM Individual WHERE Id =:leadList[0].IndividualId];
        System.assert(indieList!=null, 'Individual is not created');
    }


    @IsTest //Create - 2. 같은 이메일이 있는 경우
    public static void createDuplicateLeadTest() {
        Individual indieList = new Individual(FirstName = 'test', LastName = 'aa',
                Email__c = 'test67@daum.net', Phone__c = '1234567890',
                HasOptedOutProcessing = true, HasOptedOutSolicit = false);
        insert indieList;

        List<Lead> leadList = new List<Lead>();
        Lead con = new Lead(LastName='testUser', Email='test67@daum.net', Company='companyName');
        leadList.add(con);

        //Insert Data
        insert leadList;

        //트리거에서 넣은 값을 불러와서 조회
        Lead LeadResults = [SELECT IndividualId FROM Lead WHERE Email='test67@daum.net'];
        System.debug(LeadResults);
        System.assertEquals(LeadResults.IndividualId, indieList.Id);
    }



    @IsTest // Lead Update 관련 Individual 속성값들 변경
    public static void updateLeadTest() {
        List<Lead> leadList = new List<Lead>();

        for(Integer i=1; i<=10; i++) {
            Lead lead = new Lead();
            lead.Company = 'companyName';
            lead.LastName = 'test' + i;
            lead.Email = 'test@naver.com' + i;
            lead.Phone = '0101234123' + i;
            lead.HasOptedOutSolicit__c = true;
            lead.HasOptedOutProcessing__c = true;
            leadList.add(lead);
            System.debug('conList' + leadList);
        }

        Test.startTest();
        insert leadList;
        Test.stopTest();

        List<Lead> updateConList = [SELECT Id, Name FROM Lead WHERE  Id=: leadList[0].Id];
        System.debug('updateConList 체크 : ' + updateConList);
        System.assertEquals('test1', updateConList[0].Name);
    }
}