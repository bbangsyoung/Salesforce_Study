//Queueable 대기
public with sharing class AsyncExecution implements Queueable {
    private final User user;
    private final Individual indie;

    public AsyncExecution(User user, Individual indie) {
        this.user = user;
        this.indie = indie;
    }

    public void execute(QueueableContext context) {
        System.debug('-------------Queueable Start');
        //System.debug('들어온 indie체크 좀 ' + indie);
        //System.debug('들어온 indie.HasOptedOutProcessing__c 체크 좀 ' + indie.HasOptedOutProcessing);

        user.IndividualId = indie.Id;
        user.HasOptedOutSolicit__c = indie.HasOptedOutSolicit;
        user.HasOptedOutProcessing__c = indie.HasOptedOutProcessing;
        System.debug('큐어블 나가기전에 user 체크좀 : ' + user);
        update user;
        System.debug('-------------Queueable End');
    }
}