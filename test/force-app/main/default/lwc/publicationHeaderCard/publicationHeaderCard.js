import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import SIMAPMC from "@salesforce/messageChannel/SimapMessageChannel__c";

const MC_ORIGIN = 'publication_header_card'

const CARD_CLASSES = {
    Visited: 'slds-card card-visited',
    Converted: 'slds-card card-converted',
    New: 'slds-card card-new'
}

const COUNTRY_LABELS = {
    CH: 'Suisse',
}

export default class publicationHeaderCard extends LightningElement {
    @api publication
    _actionStatusClass
    projetUrl

    @wire(MessageContext) messageContext;

    get actionStatusClass() {
        return CARD_CLASSES[this._actionStatusClass]
    }

    get createdByInfo() {
        if (!this.publication.creationUser && !this.publication.creationDate) {
            return ''
        }
        return `Consultée par ${this.publication.creationUser} le ${this.publication.creationDate}`
    }

    get title() {
        return this.publication.title.fr || this.publication.title.de || this.publication.title.it || this.publication.title.en
    }

    get procOfficeName() {
        return this.publication.procOfficeName.fr || this.publication.procOfficeName.de || this.publication.procOfficeName.it || this.publication.procOfficeName.en
    }

    get orderAddress() {
        const address = this.publication.orderAddress
        if (!address) {
            return ''
        }
        const city = address.city?.fr || address.city?.de || address.city?.it || address.city?.en
        const locality = [address.postalCode, city].filter(Boolean).join(' ')
        const country = COUNTRY_LABELS[address.countryId] || address.countryId
        return [locality, address.cantonId, country].filter(Boolean).join(', ')
    }

    connectedCallback() {
        this.projetUrl = this.publication.projetUrl
        this._actionStatusClass = this.publication.actionStatus
    }

    seePublication() {
        if (this.publication.actionStatus !== 'Converted') {
            this._actionStatusClass = 'Visited'
        }
        const payload = {
            origin: MC_ORIGIN,
            type: 'publication-detail',
            publication: this.publication,
            shouldDisplayModal: true,
        }
        console.log(MC_ORIGIN, ' sending event', payload)
        publish(this.messageContext, SIMAPMC, payload)
    }

    seeProjet() {
        const url = this.projetUrl;
        window.open(url, '_blank');
    }

}