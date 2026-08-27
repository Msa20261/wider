import { LightningElement, track, api } from 'lwc';
import getProjetsWithAccount from '@salesforce/apex/ProjetService.getProjetsWithAccount';
import getProjet from '@salesforce/apex/ProjetService.getProjet';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Opportunity_map_filter extends LightningElement {

    allOptions = {
        label: 'Voir tout',
        value: null,
        key: 'all'
    }

    @api recordId
    @track projets = false
    @track accounts = [this.allOptions]
    @track categories = [this.allOptions]
    @track creationsDate = [this.allOptions]
    @track etapes = [this.allOptions]
    @track mandants = [this.allOptions]
    @track selectedAccount = null
    @track selectedCategory = null
    @track selectedDate = null
    @track selectedEtape = null
    @track selectedMandant = null

    async connectedCallback() {
        try {
            const data = this.recordId
                ? await getProjet({ projetId: this.recordId })
                : await getProjetsWithAccount()
            this.projets = JSON.parse(data)
            this.projets.forEach(projet => {
                if (projet.Nom_du_compte__r && !this.accounts.some(account => account.value === projet.Nom_du_compte__r.Id)) {
                    this.accounts.push({
                        label: projet.Nom_du_compte__r.Name,
                        value: projet.Nom_du_compte__r.Id,
                        key: projet.Nom_du_compte__r.Id
                    })
                }
                let year = new Date(projet.CreatedDate).getUTCFullYear();
                year = year.toString()
                if (!this.creationsDate.some(date => date.value === year)) {
                    this.creationsDate.push({
                        label: year,
                        value: year,
                        key: year
                    })
                }
                if (projet.Mandant__r && !this.mandants.some(mandant => mandant.value === projet.Mandant__r.Id)) {
                    this.mandants.push({
                        label: projet.Mandant__r.Name,
                        value: projet.Mandant__r.Id,
                        key: projet.Mandant__r.Id
                    })
                }
                if (projet.Etape__c && !this.etapes.some(etape => etape.value === projet.Etape__c)) {
                    this.etapes.push({
                        label: projet.Etape__c,
                        value: projet.Etape__c,
                        key: projet.Etape__c
                    })
                }
            })
        } catch (error) {
            console.error(error)
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Erreur lors du chargement des données',
                variant: 'error',
              });
            this.dispatchEvent(evt);
        }
    }

    handleAccountSelection(e) {
        this.selectedAccount = e.detail.value
    }

    handleCategorySelection(e) {
        this.selectedCategory = e.detail.value
    }

    handleDateSelection(e) {
        this.selectedDate = e.detail.value
    }

    handleEtapeSelection(e) {
        this.selectedEtape = e.detail.value
    }

    handleMandantSelection(e) {
        this.selectedMandant = e.detail.value
    }

}