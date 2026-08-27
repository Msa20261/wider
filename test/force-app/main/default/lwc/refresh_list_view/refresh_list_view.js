import { LightningElement, track, wire } from "lwc";
import { publish, MessageContext } from 'lightning/messageService';
import SIMAPMC from "@salesforce/messageChannel/SimapMessageChannel__c";

const MC_ORIGIN = 'refresh_list_view'

export default class NotificationConsole extends LightningElement {
    lastItem

    @wire(MessageContext) messageContext;

    handleFlowStatusChange(e) {
        console.log(MC_ORIGIN + ' flow event', e)
        if (e.detail.status === 'FINISHED') {
            const payload = {
                origin: MC_ORIGIN,
                type: 'fetch-simap-criteria',
                lastItem: null
            }
            console.log(MC_ORIGIN, ' sending event', payload)
            publish(this.messageContext, SIMAPMC, payload)
        }
    }

}