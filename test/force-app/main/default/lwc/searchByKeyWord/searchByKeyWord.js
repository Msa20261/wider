import { LightningElement, track, wire } from "lwc";
import { publish, MessageContext } from 'lightning/messageService';
import SIMAPMC from "@salesforce/messageChannel/SimapMessageChannel__c";

const MC_ORIGIN = 'SearchByKeyWord'
const SIMAP_MINIMUM_KEYWORD_LENGTH = 3

export default class SearchByKeyWord extends LightningElement {
    keyWord = null;
    _searchAuthorization = false

    get searchAuthorization() {
        return this._searchAuthorization
    }

    @wire(MessageContext) messageContext;

    handleInputChange(e) {
        this.keyWord = e.detail.value.trim()
        this._searchAuthorization = this.keyWord.length >= SIMAP_MINIMUM_KEYWORD_LENGTH
    }

    triggerSimapSearch() {
        if (!this._searchAuthorization) {
            return
        }
        const payload = {
            origin: MC_ORIGIN,
            type: 'fetch-simap-keyword',
            keyWord: this.keyWord,
            lastItem: null
        }
        console.log(MC_ORIGIN, ' sending event', payload)
        publish(this.messageContext, SIMAPMC, payload)
    }

    handleEnter(e) {
        if (e.key === 'Enter' && this._searchAuthorization) {
            this.triggerSimapSearch()
        }
    }

}