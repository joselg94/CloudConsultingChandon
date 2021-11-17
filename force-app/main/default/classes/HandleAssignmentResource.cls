public with sharing class HandleAssignmentResource {
  public static void HandleAssignmentResource(List<Resource_Project_Rol__c> newResources) {
    List<Id> userIds = new List<Id>();
    List<Id> projectRoleIds = new List<Id>();

    for (Resource_Project_Rol__c r : newResources) {
      if (!userIds.contains(r.User__c)) {
        userIds.add(r.User__c);
      }
      if (!projectRoleIds.contains(r.Project_Rol__c)) {
        projectRoleIds.add(r.Project_Rol__c);
      }
    }

    List<Resource_Project_Rol__c> actualResource = [
      SELECT Id, StartDate__c, StopDate__c, User__c
      FROM Resource_Project_Rol__c
      WHERE User__c IN :userIds
      AND Project_Rol__r.Project__r.Status__c != 'Completed'
    ];

    if (actualResource.size() > 0) {
        Map<Id, List<Resource_Project_Rol__c>> ResourceProjectRoleByUserId = new Map<Id, List<Resource_Project_Rol__c>>();

        for (Resource_Project_Rol__c r : actualResource) {
        if (ResourceProjectRoleByUserId.containsKey(r.User__c)) {
            ResourceProjectRoleByUserId.get(r.User__c).add(r);
        } else {
            ResourceProjectRoleByUserId.put(
            r.User__c,
            new List<Resource_Project_Rol__c>{ r }
            );
        }
        }
      //List
        for (Resource_Project_Rol__c nr : newResources) {
            for (Resource_Project_Rol__c r : ResourceProjectRoleByUserId.get(nr.User__c)){
                if (r.StartDate__c < nr.StartDate__c) {
                    if (!(r.StopDate__c < nr.StartDate__c)) {
                        nr.addError('Resource assigned in another project at this date');
                    }
                } else if (r.StartDate__c > nr.StopDate__c) {
                    if (!(r.StopDate__c > nr.StartDate__c)) {
                        nr.addError('Resource assigned in another project at this date');
                    }
                } else {
                    nr.addError('Resource assigned in another project at this date');
                }
            }
        }
    }
    Map<Id, Project_Rol__c> actualProjectRoleById = new Map<Id, Project_Rol__c>([SELECT Id, Project__c, Project__r.StartDate__c, Project__r.StopDate__c 
                                                                                    FROM Project_Rol__c 
                                                                                    WHERE Id IN :projectRoleIds]);


    for (Resource_Project_Rol__c r : newResources) {
      Project_Rol__c actualProjectRole = actualProjectRoleById.get(
        r.Project_Rol__c
      );
      if (
        r.StartDate__c >= actualProjectRole.Project__r.StartDate__c &&
        r.StartDate__c <= actualProjectRole.Project__r.StopDate__c
      ) {
        if (!(
          r.StopDate__c >= actualProjectRole.Project__r.StartDate__c &&
          r.StopDate__c <= actualProjectRole.Project__r.StopDate__c
        )) {
          r.addError('you must assign in project date');
        }
      } else {
        r.addError('you must assign in project date');
      }
    }
  }
}

// for (Resource_Project_Rol__c nr : newResources) {
//     for (Resource_Project_Rol__c r : ResourceProjectRoleByUserId.get(nr.User__c)){
//         if (r.StartDate__c < nr.StartDate__c) {
//             if (r.StopDate__c < nr.StartDate__c) {
//             } else {
//                 nr.addError('Resource assigned in another project at this date');
//             }
//         } else if (r.StartDate__c > nr.StopDate__c) {
//             if (r.StopDate__c > nr.StartDate__c) {
//             //insert
//             } else {
//             nr.addError('Resource assigned in another project at this date');
//             }
//         } else {
//         nr.addError('Resource assigned in another project at this date');
//         }
//     }
// }