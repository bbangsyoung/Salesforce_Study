@IsTest
public with sharing class IndividualToUser_Test {
    //Individual OpOut 관련필드 수정 시 Individual.Email__c와 User.Email 조회 후 같으면 User.IndividualID 삽입

    @TestSetup
    public static void setup() {
        List<User> userList = new List<User>();
        User user = new User(LastName = 'test2222', Email = 'test7777@naver.com', Alias = 'test', Username = 'test@naverddwdw.com',
                            CommunityNickname = 'Chatter Expert2', TimeZoneSidKey = 'Asia/Seoul', LocaleSidKey = 'ko',
                            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ProfileId = '00e2w0000047QAaAAM');
        userList.add(user);
        insert userList;

        Individual indies = new Individual(LastName = 'lee', Email__c = 'test7777@naver.com', HasOptedOutProcessing = true, HasOptedOutSolicit = true);
        insert indies;
    }


    @IsTest //Individual.HasOptedOutProcessing 수정 시
    public static void updateIndividualTest() {

        List<Individual> indieList = new List<Individual>([
                SELECT Id, Email__c, HasOptedOutProcessing, HasOptedOutSolicit
                FROM Individual
                WHERE Email__c = 'test7777@naver.com'
        ]);

        Individual indieUpdate = new Individual();
        for (Individual indieTest : indieList) {
            System.debug(indieTest);
            indieUpdate = indieTest;
        }
        indieList[0].HasOptedOutProcessing = false;
        System.debug('indieUpdate 값 : ' + indieUpdate);
        indieUpdate.HasOptedOutProcessing = false;
        System.debug('indieUpdate 값 : ' + indieUpdate);
        System.debug(indieList[0].HasOptedOutProcessing);

        Test.startTest();
        {
            update indieList; //트리거 발동시점 ------ ?
            System.debug('업데이트 뒤 여부' + indieUpdate.HasOptedOutProcessing);
        }
        Test.stopTest();

        /* 이렇게하면 Queueable 종료 X 위처럼 start/Stop 나눠서 작성.
           System.debug('indiv.id :' + indie.Id);
           indie.HasOptedOutProcessing = false;
           update indie; //트리거 발동시점
        */

        List<User> userCheck = new List<User>([
                SELECT Id, Name, IndividualId, HasOptedOutSolicit__c, HasOptedOutProcessing__c
                FROM User
                WHERE IndividualId = :indieUpdate.Id
        ]);
        System.debug(userCheck);
        System.assertNotEquals(true, userCheck.isEmpty());
        System.assertEquals(userCheck[0].IndividualId, indieUpdate.Id);

        User userTest = new User();
        for (User user : userCheck) {
            if (user.IndividualId != null) {
                System.debug(user);
                userTest = user;
            }
        }
        System.debug('userTest 체크 : ' + userTest);

        System.debug('userTest.HasOptedOutSolicit__c : ' + userTest.HasOptedOutSolicit__c);
        System.debug('indie.HasOptedOutSolicit : ' + indieUpdate.HasOptedOutSolicit);
        System.assertEquals(userTest.HasOptedOutSolicit__c, true);
        System.assertEquals(userTest.HasOptedOutSolicit__c, indieUpdate.HasOptedOutSolicit);


        indieList = new List<Individual>([
                SELECT Id, Email__c, HasOptedOutProcessing, HasOptedOutSolicit
                FROM Individual
                WHERE Email__c = 'test7777@naver.com'
        ]);
        Individual indieTest = new Individual();
        for (Individual indieTest2 : indieList) {
            System.debug(indieTest2);
            indieUpdate = indieTest2;
        }

        System.debug('userTest.HasOptedOutProcessing__c : ' + userTest.HasOptedOutProcessing__c);
        System.debug('indie.HasOptedOutProcessing : ' + indieUpdate.HasOptedOutProcessing); //false
        System.assertEquals(userTest.HasOptedOutProcessing__c, indieUpdate.HasOptedOutProcessing);


    }

    @IsTest //비동기 강제실행
    public static void updateIndividualQueueableTest() {

        //원래있는 유저 뽑아오기
        User user = ([
                SELECT Id, IndividualId, HasOptedOutSolicit__c, HasOptedOutProcessing__c
                FROM USER
                WHERE Email = 'test@naver.com'
        ]);

        Individual indie = new Individual(
                Id = '0PK2w000000b3apGAA', LastName = 'man',
                HasOptedOutProcessing = true, HasOptedOutSolicit = true
        );

        //비동기 프로세스를 강제 startTest/stopTest
        Test.startTest();
        System.enqueueJob(new AsyncExecution(user, indie));
        Test.stopTest();

        user = ([SELECT IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM User WHERE IndividualId = :indie.Id]);
        System.debug('users : ' + user);
        System.assertNotEquals(user, null);
        System.assertEquals(user.IndividualId, indie.Id); //IndividualID
        System.assertEquals(user.HasOptedOutSolicit__c, indie.HasOptedOutSolicit); //HasOptedOutSolicit__c
        System.assertEquals(user.HasOptedOutProcessing__c, indie.HasOptedOutProcessing); //HasOptedOutProcessing__c
    }
}