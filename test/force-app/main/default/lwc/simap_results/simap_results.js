import { LightningElement, wire, track } from 'lwc';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import SIMAPMC from "@salesforce/messageChannel/SimapMessageChannel__c";
import searchByCriteria from '@salesforce/apex/SimapHeadersService.searchByCriteria';
import searchByKeyWord from '@salesforce/apex/SimapHeadersService.searchByKeyWord';
import searchByCodeCfcBkp from '@salesforce/apex/SimapHeadersService.searchByCodeCfcBkp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MC_ORIGIN = 'simap_results'
const NEW_STATUS = 'New'
const VISITED_STATUS = 'Visited'
const CONVERTED_STATUS = 'Converted'
const ACTION_STATUS = [
    { label: 'Toutes', value: null },
    { label: 'Non vues', value: NEW_STATUS },
    { label: 'Consultées', value: VISITED_STATUS },
    { label: 'Converties', value: CONVERTED_STATUS },
]

export default class Simap_results extends LightningElement {

    subscription
    lastItem = null
    keyWord = null
    searchContext = null
    @track userFilters = {}
    apexFilters = {
        cantonalEntities: [],
        simapCodesCPV: [],
    }
    publicationOnDisplay = null
    _publications = []
    _displayFetchButton
    _displayModal

    @wire(MessageContext) messageContext;

    get publications() {
        const userFilters = Object.entries(this.userFilters)
        if (!userFilters.length) {
            return this._publications
        }
        return this._publications.filter(pub => userFilters.every(([key, value]) => (pub[key] === value)))
    }

    get publicationsFetched() {
        return this._publications.length
    }

    get publicationsLength() {
        return this.publications.length
    }

    get displayFetchButton() {
        return this._displayFetchButton
    }

    get displayModal() {
        return this._displayModal
    }

    get options() {
        return ACTION_STATUS;
    }

    get currentKeyWord() {
        return this.keyWord
    }

    async connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (this.subscription) return;
        this.subscription = subscribe(this.messageContext, SIMAPMC, async (event) => {
            if (event.origin === MC_ORIGIN) return
            console.log(MC_ORIGIN + 'receive event', event)
            if (event.type === 'fetch-simap-criteria') {
                this.reinitSearch(event.lastItem)
                this.searchContext = 'criteria'
                this.handleSearchByCriteria()
            }
            if (event.type === 'fetch-simap-keyword') {
                this.reinitSearch(event.lastItem, event.keyWord)
                this.searchContext = 'keyword'
                this.handleSearchByKeyWord()
            }
            if (event.type === 'publication-detail') {
                this._displayModal = event.shouldDisplayModal
                if (event.publication) {
                    this.publicationOnDisplay = event.publication
                    this.updatePublicationStatus(event.publication.id, VISITED_STATUS)
                }
            }
            if (event.type === 'fetch-simap-code-cfcbkp') {
                this.reinitSearch(event.lastItem, event.codeCfcBkp)
                this.searchContext = 'codeCfcBkp'
                this.handleSearchByCodeCfcBkp()
            }
        });
    }

    updatePublicationStatus(publicationId, status) {
        this._publications.find(pub => pub.id === publicationId).actionStatus = status
    }

    reinitSearch(lastItem, keyWord) {
        this._publications = []
        this.keyWord = keyWord
        this.lastItem = lastItem
        this._displayFetchButton = false
        this.userFilters = {}
    }

    handleSearch() {
        if (this.searchContext === 'criteria') {
            this.handleSearchByCriteria()
        }
        if (this.searchContext === 'keyword') {
            this.handleSearchByKeyWord()
        }
        if (this.searchContext === 'codeCfcBkp') {
            this.handleSearchByCodeCfcBkp()
        }
    }

    async handleSearchByCriteria() {
        try {
            const response = await searchByCriteria({ lastItem: this.lastItem})
            const result = JSON.parse(response)
            if (this.checkEndOfSearch(result.projects.length)) return
            const areFiltersTheSame = this.checkChangeInCriteria(result.filters)
            this._displayFetchButton = true
            this.lastItem = result.pagination.lastItem
            if (areFiltersTheSame) {
                this._publications = [...result.projects, ...this._publications]
                return
            }
            this.updateFilters(result.filters);
            this._publications = result.projects
        } catch(e) {
            console.error(e);
        }
    }

    async handleSearchByKeyWord() {
        try {
            const response = await searchByKeyWord({ keyWord: this.keyWord, lastItem: this.lastItem})
            const result = JSON.parse(response)
            if (this.checkEndOfSearch(result.projects.length)) return
            this._displayFetchButton = true
            this.lastItem = result.pagination.lastItem
            this._publications = [...result.projects, ...this._publications]
        } catch(e) {
            console.error(e);
        }
    }

    async handleSearchByCodeCfcBkp() {
        try {
            const response = await searchByCodeCfcBkp({ codeCfcBkp: this.keyWord, lastItem: this.lastItem})
            const result = JSON.parse(response)
            if (this.checkEndOfSearch(result.projects.length)) return
            this._displayFetchButton = true
            this.lastItem = result.pagination.lastItem
            this._publications = [...result.projects, ...this._publications]
        } catch(e) {
            console.error(e);
        }
    }

    checkEndOfSearch(resultsNumber) {
        if (!resultsNumber && !this.lastItem) {
            this.displayToastMessage('FIN', 'Aucune publication ne correspond à votre recherche', 'info')
            return true
        }
        if (!resultsNumber) {
            this.displayToastMessage('FIN', 'Toutes les publications correspondant à vos critères de recherche ont été récupérées', 'success')
            return true
        }
        return false
    }

    checkChangeInCriteria(incomingFilters) {
        const areFiltersTheSame = Object.entries(this.apexFilters).every(([key, value]) => {
            const hasSameLength = value.length === incomingFilters[key].length
            const hasSameValues = value.every(filter => incomingFilters[key].find(incomingFilter => incomingFilter.Id === filter.Id))
            return hasSameLength && hasSameValues
        })
        return areFiltersTheSame
    }

    updateFilters(newFilters) {
        this.apexFilters = newFilters;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    displayToastMessage(title, message, variant) {
        const toastEvent = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: 'dismissable',
        });
        this.dispatchEvent(toastEvent);
    }

    handleOptionChange(e) {
        console.log(e)
        const filterValue = e.detail.value
        const filterName = e.target.dataset.filter
        if (!filterValue) {
            const { [filterName] : currentFilter, ...rest } = this.userFilters
            this.userFilters = rest
            return
        }
        this.userFilters = { ...this.userFilters, [filterName]: filterValue }
    }

}