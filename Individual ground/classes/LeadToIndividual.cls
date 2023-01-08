public with sharing class LeadToIndividual extends TriggerHandler {

    public override void beforeInsert() {
        this.createLead();
    }

    public override void afterUpdate() {
        this.updateLead();
    }

    //Lead Insert
    public void createLead() {
        for (Lead lead : (List<Lead>) Trigger.new) {

            String checkEmail = lead.Email; //lead.Email 확인해야함 - Individual 같은 email 있을 경우 그 Individual ID를 새로운 Lead IndividualID로 입력
            String checkID = '';
            Boolean duplicate = false;
            System.debug('이메일은 -' + checkEmail + ' ' + duplicate);

            //전체 Individual 을 가져와서 Email 동일한지 조회
            List<Individual> indieItemList = [SELECT Id, Email__c, (SELECT Email, IndividualId FROM Leads) FROM Individual];

            for (Individual indites : indieItemList) {
                if (lead.Email == indites.Email__c) {
                    duplicate = true;
                    System.debug('이메일이 같은 Individual의 ID는 ' + duplicate + indites.Id);
                    checkID = indites.id;
                } else {
                    System.debug('X');
                }
            }

            //Email이 같지 않을 때에만 indiv Insert
            //기존에 Individual에 등록된 Email과 같으면 위에서 담아뒀던 Individual의 ID를 lead.IndividualId에 삽입
            if (!duplicate) {
                Individual indie = new Individual(FirstName = lead.FirstName, LastName = lead.LastName,
                        Email__c = lead.Email, Phone__c = lead.Phone,
                        HasOptedOutProcessing = lead.HasOptedOutProcessing__c,
                        HasOptedOutSolicit = lead.HasOptedOutSolicit__c);
                System.debug('IndividualId로 들어간 값은 , 기존에 없는 아이디 ' + indie.Id);
                insert indie;
            } else {
                lead.IndividualId = checkID;
                System.debug('IndividualId로 들어간 값은 , 기존에 있는 Individual.id ' + checkID);
            }
        }
    }

    //Lead update
    public void updateLead() {
        Set<Id> setId = new Set<Id>();
        for (Lead lead : (List<Lead>) Trigger.old) {
            setId.add(lead.IndividualId);
        }
        List<Individual> indieItemList = [
                SELECT Id, Name, Phone__c, Email__c, HasOptedOutProcessing, HasOptedOutSolicit, (SELECT Id, Phone, Email, IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM Leads)
                FROM Individual
                WHERE Id IN :setId
        ];
        System.debug('업데이트 체크' + indieItemList);

        for (Individual indie : indieItemList) {
            for (Lead lead : indie.Leads) {
                if (lead.IndividualId == indie.Id) {
                    indie.Phone__c = lead.Phone;
                    indie.Email__c = lead.Email;
                    indie.HasOptedOutProcessing = lead.HasOptedOutProcessing__c;
                    indie.HasOptedOutSolicit = lead.HasOptedOutSolicit__c;
                    update indieItemList;
                }
            }
        }
    }
}