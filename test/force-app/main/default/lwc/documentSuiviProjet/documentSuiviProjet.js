import { LightningElement, api, wire } from 'lwc';
import getSuiviDocuments from '@salesforce/apex/DocumentSuiviProjetController.getSuiviDocuments';

const CHECK_ICON = 'utility:check';
const DASH_ICON = 'utility:dash';

export default class DocumentSuiviProjet extends LightningElement {
    @api recordId;

    totalConfirme = 0;
    totalEnCours = 0;
    totalEnCoursPondere = 0;
    totalFacture = 0;
    documents = [];
    repartitionParStatut = [];
    error;
    isLoading = true;

    @wire(getSuiviDocuments, { projetId: '$recordId' })
    wiredSuivi({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.totalConfirme = data.totalConfirme;
            this.totalEnCours = data.totalEnCours;
            this.totalEnCoursPondere = data.totalEnCoursPondere;
            this.totalFacture = data.totalFacture;
            this.documents = data.documents.map((doc, index) => ({
                ...doc,
                key: doc.reference ? doc.reference : 'doc-' + index,
                badgeClass: this.badgeClassFor(doc.categorie),
                offertIcon: doc.offert ? CHECK_ICON : DASH_ICON,
                commandeIcon: doc.commande ? CHECK_ICON : DASH_ICON,
                factureIcon: doc.facture ? CHECK_ICON : DASH_ICON
            }));
            this.repartitionParStatut = (data.repartitionParStatut || [])
                .slice()
                .sort((a, b) => b.totalMontant - a.totalMontant)
                .map((r, index) => ({ ...r, key: 'statut-' + index }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.documents = [];
            this.repartitionParStatut = [];
        }
    }

    badgeClassFor(categorie) {
        if (categorie === 'Confirmé') {
            return 'slds-badge slds-theme_success';
        }
        if (categorie === 'Facturé') {
            return 'slds-badge slds-badge_inverse';
        }
        if (categorie === 'En cours') {
            return 'slds-badge slds-theme_warning';
        }
        return 'slds-badge';
    }

    get hasDocuments() {
        return this.documents && this.documents.length > 0;
    }

    get hasRepartition() {
        return this.repartitionParStatut && this.repartitionParStatut.length > 0;
    }

    get hasError() {
        return !!this.error;
    }
}
