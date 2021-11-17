import { LightningElement, api, wire } from "lwc";
import resourceProjectList from "@salesforce/apex/GetResourceController.resourceProjectList";
import {
  subscribe,
  MessageContext,
  APPLICATION_SCOPE
} from "lightning/messageService";
import ResourceMC from "@salesforce/messageChannel/ResourceMessageChannel__c";
import { refreshApex } from "@salesforce/apex";

export default class ResourceList extends LightningElement {
  @api recordId;
  columns = [
    { label: "Name", fieldName: "Name", type: "text" },
    { label: "Role", fieldName: "Role__c", type: "text" },
    {
      label: "Start Date",
      fieldName: "StartDate__c",
      type: "date-local"
    },
    {
      label: "End Date",
      fieldName: "StopDate__c",
      type: "date-local"
    }
  ];
  response;
  title = "test";
  subscription;
  test;
  @wire(MessageContext) messageContext;

  subscribeMC() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      ResourceMC,
      (message) => refreshApex(this.test),
      { scope: APPLICATION_SCOPE }
    );
  }

  connectedCallback() {
    this.subscribeMC();
  }
  @wire(resourceProjectList, { recordId: "$recordId" })
  resource(res) {
    this.test = res;
    if (res.data) {
      let list = [];
      for (let i = 0; i < res.data.length; i++) {
        let obj = {
          Name: res.data[i].User__r.Name,
          Role__c: res.data[i].User__r.UserRole.Name,
          StartDate__c: res.data[i].StartDate__c,
          StopDate__c: res.data[i].StopDate__c
        };
        list.push(obj);
      }
      this.response = list;
    }
  }
}
