trigger IndividualTrigger on Individual (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new IndividualToUser().run();
}