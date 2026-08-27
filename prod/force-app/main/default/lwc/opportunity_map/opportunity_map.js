import { LightningElement, api, track } from 'lwc';
import leaflets from '@salesforce/resourceUrl/ubd_leaflets_zip';
import markercluster from '@salesforce/resourceUrl/markercluster_zip';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import switzerlandBorders from '@salesforce/resourceUrl/switzerlandGeoJson';
import opportunitiesMapCss from '@salesforce/resourceUrl/opportunities_map';
import red from '@salesforce/resourceUrl/red';
import orange from '@salesforce/resourceUrl/orange';
import green from '@salesforce/resourceUrl/green';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class UbdMap extends LightningElement {
    @api recordId
    @api projets
    _selectedAccount
    _selectedCategory
    _selectedDate
    _selectedEtape
    _selectedMandant
    @track markerGroup
    projetsMap
    overlappingMarkerSpiderfier

    @api
    get selectedAccount() {
        return this._selectedAccount
    }

    set selectedAccount(accountId) {
        this._selectedAccount = accountId
        if (this.projetsMap) {
            this.clearMarkers()
            this.addMarkers()
        }
    }

    @api
    get selectedCategory() {
        return this._selectedCategory
    }

    set selectedCategory(categoryName) {
        this._selectedCategory = categoryName
        if (this.projetsMap) {
            this.clearMarkers()
            this.addMarkers()
        }
    }

    @api
    get selectedDate() {
        return this._selectedDate
    }

    set selectedDate(date) {
        this._selectedDate = date
        if (this.projetsMap) {
            this.clearMarkers()
            this.addMarkers()
        }
    }

    @api
    get selectedEtape() {
        return this._selectedEtape
    }

    set selectedEtape(etape) {
        this._selectedEtape = etape
        if (this.projetsMap) {
            this.clearMarkers()
            this.addMarkers()
        }
    }

    @api
    get selectedMandant() {
        return this._selectedMandant
    }

    set selectedMandant(mandant) {
        this._selectedMandant = mandant
        if (this.projetsMap) {
            this.clearMarkers()
            this.addMarkers()
        }
    }


    etapeIcons = {
        // Jaune
        'Opportunité':            orange,
        'Attribution':            orange,
        'Chiffrage':              orange,
        'Ouvert':                 orange,
        'En préparation':         orange,
        'Préparation':            orange,
        'En cours':               orange,
        'Ouvert (Offre envoyée)': orange,
        'En attente':             orange,
        // Vert
        'Confirmé':               green,
        'Exécuté':                green,
        'Facturé':                green,
        'Commandé':               green,
        // Vert Gold
        'Terminé':                green,
        'Projet Terminé':         green,
        'En production':          green,
        // Rouge
        'Pas exécuté':            red,
        'Annulé':                 red,
        // default
        'default':                orange,
    }

    async connectedCallback() {
        try {
            await Promise.all([
                loadStyle(this, opportunitiesMapCss),
                loadStyle(this, `${leaflets}/leaflet.css`),
                loadStyle(this, `${markercluster}/MarkerCluster.css`)
            ]);
    
            await loadScript(this, `${leaflets}/leaflet.js`);
            await loadScript(this, `${markercluster}/leaflet.markercluster.js`);
    
            const geoJsonResponse = await fetch(switzerlandBorders);
            const data = await geoJsonResponse.json();
            
            this.switzerlandBordersData = data;
            this.initializeMap(data);
        } catch (error) {
            console.error(error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Erreur lors du chargement des données',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }

    async initializeMap(data)  {
        const anchor = this.template.querySelector('div')
        try {
            if (this.recordId) {
                const { latitude__c, longitude__c } = this.projets[0]
                this.projetsMap = window.L.map(anchor).setView([parseFloat(latitude__c), parseFloat(longitude__c)], 16);
            } else {
                this.projetsMap = window.L.map(anchor).setView([46.8, 8.2], 8);
            }

            window.L.tileLayer(
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                {
                    accessToken: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                }
            ).addTo(this.projetsMap);
            window.L.geoJSON(data, {
                style: () => ({
                    color: '#001846',
                    weight: 2,
                    fillColor: 'transparent',
                    fillOpacity: 0,
                })
            }).addTo(this.projetsMap);
            this.addMarkers()
        } catch (error){
            console.error(error)
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Erreur lors du chargement de la carte',
                variant: 'error',
              });
            this.dispatchEvent(evt);
        }            
    }

    filterProjets() {
        if (!this.selectedAccount && !this.selectedCategory && !this.selectedDate && !this.selectedEtape && !this.selectedMandant) {
            return this.projets
        }

        return this.projets.filter((projet) => {
            const matchesAccount = !this.selectedAccount || (projet.Nom_du_compte__r && projet.Nom_du_compte__r.Id === this._selectedAccount)
            const matchesDate = !this.selectedDate || new Date(projet.CreatedDate).getUTCFullYear().toString() === this._selectedDate
            const matchesEtape = !this.selectedEtape || projet.Etape__c === this._selectedEtape
            const matchesMandant = !this.selectedMandant || (projet.Mandant__r && projet.Mandant__r.Id === this._selectedMandant)

            return matchesAccount && matchesDate && matchesEtape && matchesMandant
        })
    }

    clearMarkers() {
        if (this.markerGroup) {
            this.markerGroup.clearLayers();
        }
        if (this.overlappingMarkerSpiderfier) {
            this.overlappingMarkerSpiderfier.clearLayers();
        }
    }

    addMarkers() {
        const ProjetIcon = window.L.Icon.extend({
            options: {
                iconSize: [38, 45],
                iconAnchor: [19, 49],
                popupAnchor: [0, -45],
            },
        });

        this.markerGroup = window.L.layerGroup().addTo(this.projetsMap);
        
        if (window.L && window.L.markerClusterGroup && typeof window.L.markerClusterGroup === 'function') {
            this.overlappingMarkerSpiderfier = window.L.markerClusterGroup({
                chunkedLoading: true,
                maxClusterRadius: 10,
                spiderfyOnMaxZoom: true,
                showCoverageOnHover: false,
                zoomToBoundsOnClick: true,
                iconCreateFunction: function(cluster) {
                    const count = cluster.getChildCount();
                    let className;
                    let size;

                    if (count < 10) {
                        size = 'small';
                        className = 'marker-cluster-small';
                    } else if (count < 100) {
                        size = 'medium';
                        className = 'marker-cluster-medium';
                    } else {
                        size = 'large';
                        className = 'marker-cluster-large';
                    }
                    
                    return window.L.divIcon({
                        html: `<div><span>${count}</span></div>`,
                        className: `marker-cluster ${className}`,
                        iconSize: window.L.point(40, 40)
                    });
                }
            }).addTo(this.projetsMap);
        } else {
            console.warn('MarkerCluster not available, falling back to regular markers');
        }

        this.filterProjets()
            .forEach((projet) => {
                const {
                    Etape__c,
                    latitude__c,
                    longitude__c
                } = projet
                const customPopup = this.buildPopUp(projet)

                const customOptions = {
                    className: 'custom-popup'
                };

                const icon = new ProjetIcon({ iconUrl: this.etapeIcons[Etape__c] || this.etapeIcons['default'] })
                const marker = window.L.marker([
                    parseFloat(latitude__c),
                    parseFloat(longitude__c)
                ], { icon })
                .bindPopup(customPopup, customOptions);
                
                if (this.overlappingMarkerSpiderfier && this.overlappingMarkerSpiderfier.addLayer) {
                    this.overlappingMarkerSpiderfier.addLayer(marker);
                } else {
                    marker.addTo(this.markerGroup);
                }
            })
    }

    buildPopUp ({
        Name,
        Nom_du_compte__r,
        Adresse_de_Livraison__r,
        Id,
        Etape__c,
        Mandant__r,
    }) {
        return `
            <div>
                <h2>${Name.charAt(0).toUpperCase() + Name.slice(1)}</h2>
                ${this.buildAccountBlock(Nom_du_compte__r)}
                <h2>Étape</h2>
                <span>${Etape__c || ''}</span>
                <h2>Mandant</h2>
                <span>${Mandant__r ? Mandant__r.Name : ''}</span>
                ${this.buildAddressBlock(Adresse_de_Livraison__r)}
                <a href='/lightning/r/Projet__c/${Id}/view'>Voir le projet</a>
            </div>
        `;
    }

    buildAccountBlock(Nom_du_compte__r) {
        return Nom_du_compte__r ?
            `<a href='/lightning/r/Account/${Nom_du_compte__r.Id}/view'>${Nom_du_compte__r.Name}</a>`
            : ''
    }

    // Le compte rattaché en adresse de livraison porte l'adresse qui a servi au géocodage :
    // c'est donc elle qu'affiche le popup, pour que le pin et le texte soient cohérents.
    buildAddressBlock(Adresse_de_Livraison__r) {
        if (!Adresse_de_Livraison__r) return ''

        const street     = Adresse_de_Livraison__r.Adresse_compte__street__s || ''
        const city       = Adresse_de_Livraison__r.Adresse_compte__city__s || ''
        const postalCode = Adresse_de_Livraison__r.Adresse_compte__postalCode__s || ''
        const country    = Adresse_de_Livraison__r.Adresse_compte__CountryCode__s || ''

        return `<div class='address-container' data-city=${city}>
                    <h2>Adresse de livraison</h2>
                    <span>${street}</span>
                    <span>${city}${postalCode ? ' - ' + postalCode : ''}</span>
                    <span>${country}</span>
                </div>`
    }
}