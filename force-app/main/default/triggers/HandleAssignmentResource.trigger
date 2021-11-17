trigger HandleAssignmentResource on Resource_Project_Rol__c(
  before insert,
  before update
) {
  if (Trigger.isBefore && Trigger.isInsert) {
    HandleAssignmentResource.HandleAssignmentResource(Trigger.New);
  }
}
