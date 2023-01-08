public with sharing class ContactToIndividual extends TriggerHandler {

    public override void beforeInsert() {
        this.createContact();
    }

    public override void afterUpdate() {
        this.updateContact();
    }

    //여기다 구현
    public void createContact() {
        for (Contact con : (List<Contact>) Trigger.new) {

            String checkEmail = con.Email; //con.Email 확인. Individual 같은 email 있을 경우 그 Individual ID를 새로운 Contact.IndividualId 추가
            String checkID = '';
            Boolean duplicate = false;

            //전체 Individual 가져와서 Email 동일한지 조회
            List<Individual> indieItemList = [SELECT Id, Email__c, (SELECT Email, IndividualId FROM Contacts) FROM Individual];

            for (Individual indites : indieItemList) {
                if (con.Email == indites.Email__c) {
                    duplicate = true;
                    System.debug('이메일이 같은 Individual의 ID는 ' + duplicate + indites.Id);
                    checkID = indites.Id;
                } else {
                    System.debug('이메일이 같은 Individual의 ID가 없습니다 ');
                }
            }

            //Email 같지 않을 때에만 indie Insert
            //기존에 Individual 등록된 Email 같으면 위에서 담아뒀던 Individual ID를 con.IndividualId에 삽입
            if (!duplicate) {
                Individual indie = new Individual(FirstName = con.FirstName, LastName = con.LastName,
                        Email__c = con.Email, Phone__c = con.Phone,
                        HasOptedOutProcessing = con.HasOptedOutProcessing__c,
                        HasOptedOutSolicit = con.HasOptedOutSolicit__c);
                System.debug('IndividualId로 들어간 값은 , 기존에 없는 아이디 ' + indie.Id);
                insert indie;
            } else {
                con.IndividualId = checkID;
                System.debug('IndividualId로 들어간 값은 , 기존에 있는 Individual.Id' + checkID);
            }

        }
    }

    //업데이트
    public void updateContact() {
        Set<Id> setId = new Set<Id>();
        for (Contact con : (List<Contact>) Trigger.old) {
            System.debug('들어온 CONTACT 값 확인좀 : ' + con);
            System.debug('들어온 CONTACT 값 확인좀 : ' + con.Phone);
            setId.add(con.IndividualId);
        }

        List<Individual> indivItemList = [
                SELECT Id, Name, Phone__c, Email__c, HasOptedOutProcessing, HasOptedOutSolicit,
                       (SELECT Id, Phone, Email, IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM Contacts)
                FROM Individual
                WHERE Id IN :setId
        ];
        System.debug('업데이트 체크' + indivItemList);

        for (Individual indie : indivItemList) {
            for (Contact con : indie.Contacts) {
                if (con.IndividualId == indie.Id) {
                    indie.Phone__c = con.Phone;
                    indie.Email__c = con.Email;
                    indie.HasOptedOutProcessing = con.HasOptedOutProcessing__c;
                    indie.HasOptedOutSolicit = con.HasOptedOutSolicit__c;
                    update indivItemList;
                }
            }
        }

    }

    //Contact 필드에서 해당 Indivi오 ㅏ관련된 모든 연락처 이름을 연결해줌
    //ContactObject에 필드가 있고 해당 필드에서 해당 계정과
    // 관련된 모든 연락처 이름을 연결해야 한다고 가정하면 이에 대한 Apex Trigger를 작성해야 합니다.
    //이제 다른 컨텍스트(삭제 후, 삽입 후, 삭제 취소 후)에서 작동
    public void updateContact_2() {
        Set<Id> setId = new Set<Id>();
        List<Individual> listOfAccountToBeUpdate = new List<Individual>();

        for (Contact con : (List<Contact>) Trigger.old) {
            setId.add(con.AccountId);
        }
        List<Individual> listOfAccountWithContact = [
                SELECT Id, Name, Phone__c, Email__c, HasOptedOutProcessing, HasOptedOutSolicit,
                       (SELECT Id, Phone, Email, IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM Contacts)
                FROM Individual
                WHERE Id IN :setId
        ];

        List<Contact> ccc = [SELECT Id, Phone, Email, IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM Contact];

        for (Individual acc : listOfAccountWithContact) {
            Individual newAccount = new Individual();

            for (Contact con : ccc) {
                if (acc.Email__c == con.Email) {
                    con.IndividualId = acc.Id;
                }
            }
            newAccount.Id = acc.Id;
            listOfAccountToBeUpdate.add(newAccount); //목록추가
        }
        if (!listOfAccountToBeUpdate.isEmpty()) {
            update listOfAccountToBeUpdate;
        }


    }


}