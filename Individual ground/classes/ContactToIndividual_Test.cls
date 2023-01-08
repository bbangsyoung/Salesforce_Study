@IsTest
public with sharing class ContactToIndividual_Test {

    @TestVisible
    public void setup() {
    }

    @IsTest //Contact Create - 1. 일반생성
    public static void createContactTest() {
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'ddd@naver.com';
        conList.add(con);

        //Insert Data
        Test.startTest();
        insert conList;
        System.debug(con.IndividualId + ' 1번 - con.IndividualId 체크할게요');
        Test.stopTest();
        System.debug(con.IndividualId + ' 2번 - con.IndividualId 체크할게요');

        System.debug(conList[0].IndividualId + ' 3번 - conList[0].IndividualId 체크할게요');

        List<Individual> indiList = [select id from Individual WHERE id= :conList[0].IndividualId];
        System.assert(indiList!=null, 'Individual is not created');

    }


    @IsTest //Create - 2. 같은 이메일이 있는 경우
    public static void createDuplicateContactTest() {
        Individual indivList = new Individual(FirstName = 'test', LastName = 'aa',
                Email__c = 'test67@daum.net', Phone__c = '1234567890',
                HasOptedOutProcessing = true, HasOptedOutSolicit = false);
        insert indivList;
        System.debug(indivList.id + ' - indivList.Id 체크할게요');

        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(LastName='testUser', Email='test67@daum.net');
        conList.add(con);
        System.debug(con + ' con 체크');

        //Insert Data
        insert conList;
        //트리거에서 넣은 값을 불러와서 조회
        Contact contactRe = [SELECT IndividualId from Contact WHERE Email='test67@daum.net'];
        System.debug(contactRe);

        System.debug(contactRe.IndividualId + ' - contactRe.IndividualId 체크할게요');

        System.assertEquals(contactRe.IndividualId, indivList.id);
    }



    @IsTest // Contact Update시 관련 Individual의 속성값들 변경
    public static void updateContactTest() {
        List<Contact> conList = new List<Contact>();

        for(Integer i=1; i<=10; i++) {
            Contact con = new Contact();
            con.LastName = 'test' + i;
            con.Email = 'test@naver.com' + i;
            con.Phone = '0101234123' + i;
            con.HasOptedOutSolicit__c = true;
            con.HasOptedOutProcessing__c = true;
            conList.add(con);
            System.debug('conList' + conList);
        }

        Test.startTest();
        insert conList;
        Test.stopTest();

        List<Contact> updateConList = [SELECT id, Name from Contact WHERE  id=: conList[0].id];
        System.debug('이거좀' + updateConList);
        System.assertEquals('test1', updateConList[0].Name);

    }



}