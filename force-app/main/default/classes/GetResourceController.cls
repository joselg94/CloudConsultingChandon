public with sharing class GetResourceController {
    
  @AuraEnabled(cacheable = true)
  public static List<User> getResourceByRol(String rol, Id recordId ) {

    List<Project__c> project = [SELECT StartDate__c, StopDate__c FROM Project__c WHERE Id =: recordId];
    Date startDate = project[0].StartDate__c;
    Date stopDate = project[0].StopDate__c;
    Map<Id, List<Resource_Project_Rol__c>> resourceProjectRol = new Map<Id, List<Resource_Project_Rol__c>>();
    Set<Id> busyUsers = new Set<Id>();

    List<AggregateResult> oldResources = [SELECT User__c user
                                          FROM Resource_Project_Rol__c 
                                          WHERE StopDate__c >= :startDate 
                                          AND StartDate__c <= :stopDate 
                                          AND User__r.UserRole.Name =:rol
                                          GROUP BY User__c];

    for (AggregateResult r : oldResources) {
      busyUsers.add((Id)r.get('user'));
    }
    
    return [SELECT Id, Name, UserRoleId
            FROM User 
            WHERE UserRole.Name =: rol AND Id NOT IN:busyUsers];

  } 

  @AuraEnabled(cacheable = true)
  public static List<String> getRolByProyecRol(Id recordId ) {

    List<AggregateResult> roles = [SELECT Role__c role
                                    FROM Project_Rol__c
                                    WHERE Project__c =: recordId GROUP BY Role__c];

    Set<String> currentRoles = new Set<String>();
    for (AggregateResult r : roles) {
      currentRoles.add((String)r.get('role'));
    }

    List<String> roleList = new List<String>();
    for (String r : currentRoles) {
      roleList.add(r);
    }
    
    return roleList;
  } 

  @AuraEnabled
  public static List<Resource_Project_Rol__c> insertResourceList(Object data, Id recordId){

    List<Resource_Project_Rol__c> resourceForInsert = (List<Resource_Project_Rol__c>) JSON.deserialize(
        JSON.serialize(data),
        List<Resource_Project_Rol__c>.class
    );
    List<Resource_Project_Rol__c> newResources = new List<Resource_Project_Rol__c>();

    for (Resource_Project_Rol__c ri : resourceForInsert) {
      newResources.add(new Resource_Project_Rol__c(User__c=ri.Id,StartDate__c=ri.StartDate__c, StopDate__c=ri.StopDate__c));
    }

    List<User> roleName = [SELECT UserRole.Name FROM User WHERE Id =: newResources[0].User__c];

    List<Project_Rol__c> idProjectRole = [SELECT Id FROM Project_Rol__c WHERE Role__c =: roleName[0].UserRole.Name AND Project__c =: recordId];

    for (Resource_Project_Rol__c nr : newResources) {
      nr.Project_Rol__c = idProjectRole[0].Id;
    }

    insert newResources;
    return newResources;
  }
  
  @AuraEnabled(cacheable = true)
  public static List<Project_Rol__c> getHoursByRole(String role, Id recordId ) {
  
    List<Project_Rol__c> roles =[SELECT Role__c,Quantity__c,SumRoleHours__c
                                  FROM Project_Rol__c
                                  WHERE Project__c =: recordId AND Role__c =: role];
    return roles;
  }

  @AuraEnabled(cacheable = true) 
  public static List<Resource_Project_Rol__c> resourceProjectList(Id recordId) {
    return [SELECT User__r.Name, User__r.UserRole.Name, StartDate__c,StopDate__c 
                                          FROM Resource_Project_Rol__c 
                                          WHERE Project_Rol__r.Project__c =:recordId ];
  }
}