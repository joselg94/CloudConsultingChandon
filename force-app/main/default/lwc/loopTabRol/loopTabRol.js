import { LightningElement, wire, api, track } from "lwc";
import getResourceByRol from "@salesforce/apex/GetResourceController.getResourceByRol";
import getHoursByRole from "@salesforce/apex/GetResourceController.getHoursByRole";
import getRolByProyecRol from "@salesforce/apex/GetResourceController.getRolByProyecRol";
import insertResourceList from "@salesforce/apex/GetResourceController.insertResourceList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { publish, MessageContext } from "lightning/messageService";
import ResourceMC from "@salesforce/messageChannel/ResourceMessageChannel__c";
const columns = [
  { label: "Name", fieldName: "Name", type: "text" },
  {
    label: "Start Date",
    fieldName: "StartDate__c",
    type: "date-local",
    editable: true
  },
  {
    label: "End Date",
    fieldName: "StopDate__c",
    type: "date-local",
    editable: true
  }
];
const SUCCESS_TITLE = "Success";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error";
const ERROR_VARIANT = "error";

export default class LoopTabRol extends LightningElement {
  @api recordId;
  roles;
  rol;
  error;
  columns = columns;
  draftValues = [];
  response = "";
  hours = 0;
  title = "";
  assigned = 0;
  hoursAssigned;
  wiredResult;

  @wire(MessageContext) messageContext;

  @wire(getRolByProyecRol, { recordId: "$recordId" })
  res(r) {
    this.roles = r.data;
  }

  handleActive(event) {
    this.rol = event.target.label;
    getHoursByRole({ role: this.rol, recordId: this.recordId }).then((data) => {
      this.hours = data;
    });
  }

  @wire(getHoursByRole, { role: "$rol", recordId: "$recordId" })
  gethours(res) {
    this.hoursAssigned = res;
    if (res.data) {
      this.assigned = res.data[0].SumRoleHours__c;
      this.hours = res.data[0].Quantity__c;
      this.title = `Hours to assign ${this.hours}, assigned ${this.assigned}`;
    }
  }

  @wire(getResourceByRol, { rol: "$rol", recordId: "$recordId" })
  resource(resp) {
    this.wiredResult = resp;
    this.response = resp.data;
  }

  handleSave(event) {
    const insertFields = event.detail.draftValues;

    insertResourceList({ data: insertFields, recordId: this.recordId })
      .then((res) => {
        const toastEvent = new ShowToastEvent({
          variant: SUCCESS_VARIANT,
          message: res,
          title: SUCCESS_TITLE
        });
        this.dispatchEvent(toastEvent);

        publish(this.messageContext, ResourceMC, { recordId: this.recordId });

        this.draftValues = [];
        refreshApex(this.wiredResult);
        return refreshApex(this.hoursAssigned);
      })
      .catch((err) => {
        const toastEvent = new ShowToastEvent({
          variant: ERROR_VARIANT,
          message: err.message,
          title: ERROR_TITLE
        });
        this.dispatchEvent(toastEvent);
      });
  }
}
