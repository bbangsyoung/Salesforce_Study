public with sharing class IndividualToUser extends TriggerHandler {


    public override void afterUpdate() {
        this.IndividualUpdate();
    }

    public void IndividualUpdate() {
        //수정 시 전체 User List 불러와서 user.Email 체크
        System.debug('IndividualUpdate 메소드 시작-------------');
        Boolean changeCheck = false;


        for (Individual indie : (List<Individual>) Trigger.new) {
            System.debug('업데이트 받은 individaual indie.HasOptedOutProcessing 값 확인' + indie.HasOptedOutProcessing);
            for (Individual indieold : (List<Individual>) Trigger.old) {
                System.debug('individual.HasOptedOutProcessing 원래값 ' + indieold.HasOptedOutProcessing);

                //기존 HasOptedOutProcessing 값과 새로운 값이 다르면 changeCheck를 true로 설정해서 아래 큐어블 실행 여부로 사용
                if(indie.HasOptedOutProcessing != indieold.HasOptedOutProcessing || indie.HasOptedOutSolicit != indieold.HasOptedOutSolicit) {
                    changeCheck = true;
                }
            }

            //Trigger.new의 HasOptedOutProcessing값과 old의 값이 같지않을 경우 발동

                List<User> userList = [SELECT Id, Email, IndividualId, HasOptedOutProcessing__c, HasOptedOutSolicit__c FROM User];
                for (User user1 : userList) {
                    if (indie.Email__c == user1.Email && changeCheck == true) {
                        System.debug('Individual.Id 와 Email 과 같은 User.ID가 존재 : ' + user1.Id);
                        Id jobID = System.enqueueJob(new AsyncExecution(user1, indie)); //Queueable Start
                    } else {
                        System.debug('X');
                    }
                }

        }
    }

}