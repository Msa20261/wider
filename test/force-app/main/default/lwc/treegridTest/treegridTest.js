import { LightningElement, track } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import treeGridDefaultCss from '@salesforce/resourceUrl/treeGridDefaultCss';

export default class LightningTreeGrid extends LightningElement {
    @track expandedRows = [];
    @track treeData = [];

    columns = [
        {
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'name' },
                name: { fieldName: 'buttonName' },
                variant: { fieldName: 'buttonVariant' },
                iconName: { fieldName: 'buttonIcon' },
                iconPosition: 'left',
                class: { fieldName: 'buttonClass' }
            },
            initialWidth: 200,
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Type',
            fieldName: 'type',
            type: 'text'
        },
        {
            label: 'Valeur',
            fieldName: 'value',
            type: 'text'
        }
    ];

    connectedCallback() {
        loadStyle(this, treeGridDefaultCss);
        this.treeData = this.generateSampleData();
        // Développer le premier niveau par défaut
        // this.expandedRows = this.treeData.map(item => item.id);
    }

    generateSampleData() {
        return [
            {
                id: '1',
                name: 'Racine 1',
                type: 'Catégorie',
                value: '100',
                buttonName: 'toggle_1',
                buttonVariant: 'neutral',
                buttonIcon: 'utility:open_folder',
                buttonClass: 'uniform-button',
                _children: [
                    {
                        id: '1-1',
                        name: 'Enfant 1.1',
                        type: 'Sous-catégorie',
                        value: '50',
                        buttonName: 'toggle_1-1',
                        buttonVariant: 'neutral',
                        buttonIcon: 'utility:open_folder',
                        buttonClass: 'uniform-button',
                        _children: [
                            {
                                id: '1-1-1',
                                name: 'Feuille 1.1.1',
                                type: 'Élément',
                                value: '25',
                                buttonName: 'leaf_1-1-1',
                                buttonVariant: 'neutral',
                                buttonIcon: 'utility:smiley',
                                buttonClass: 'uniform-button'
                            },
                            {
                                id: '1-1-2',
                                name: 'Feuille 1.1.2',
                                type: 'Élément',
                                value: '25',
                                buttonName: 'leaf_1-1-2',
                                buttonVariant: 'neutral',
                                buttonIcon: 'utility:smiley',
                                buttonClass: 'uniform-button'
                            }
                        ]
                    },
                    {
                        id: '1-2',
                        name: 'Enfant 1.2',
                        type: 'Sous-catégorie',
                        value: '50',
                        buttonName: 'leaf_1-2',
                        buttonVariant: 'neutral',
                        buttonIcon: 'utility:smiley',
                        buttonClass: 'uniform-button'
                    }
                ]
            },
            {
                id: '2',
                name: 'Racine 2',
                type: 'Catégorie',
                value: '200',
                buttonName: 'toggle_2',
                buttonVariant: 'neutral',
                buttonIcon: 'utility:open_folder',
                buttonClass: 'uniform-button',
                _children: [
                    {
                        id: '2-1',
                        name: 'Enfant 2.1',
                        type: 'Sous-catégorie',
                        value: '100',
                        buttonName: 'leaf_2-1',
                        buttonVariant: 'neutral',
                        buttonIcon: 'utility:smiley',
                        buttonClass: 'uniform-button'
                    },
                    {
                        id: '2-2',
                        name: 'Enfant 2.2',
                        type: 'Sous-catégorie',
                        value: '100',
                        buttonName: 'toggle_2-2',
                        buttonVariant: 'neutral',
                        buttonIcon: 'utility:open_folder',
                        buttonClass: 'uniform-button',
                        _children: [
                            {
                                id: '2-2-1',
                                name: 'Feuille 2.2.1',
                                type: 'Élément',
                                value: '50',
                                buttonName: 'leaf_2-2-1',
                                buttonVariant: 'neutral',
                                buttonIcon: 'utility:smiley',
                                buttonClass: 'uniform-button'
                            },
                            {
                                id: '2-2-2',
                                name: 'Feuille 2.2.2',
                                type: 'Élément',
                                value: '50',
                                buttonName: 'leaf_2-2-2',
                                buttonVariant: 'neutral',
                                buttonIcon: 'utility:smiley',
                                buttonClass: 'uniform-button'
                            }
                        ]
                    }
                ]
            },
            {
                id: '3',
                name: 'Racine 3 (sans enfants)',
                type: 'Catégorie',
                value: '300',
                buttonName: 'leaf_3',
                buttonVariant: 'neutral',
                buttonIcon: 'utility:smiley',
                buttonClass: 'uniform-button'
            }
        ];
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        // Vérifier si c'est un bouton de toggle (commence par "toggle_")
        if (row.buttonName && row.buttonName.startsWith('toggle_')) {
            this.toggleRow(row.id);
        } else {
            console.log('Action sur feuille:', row);
            // Ajouter ici la logique pour les boutons feuille
        }
    }

    handleToggle(event) {
        const rowName = event.detail.name;
        const isExpanded = event.detail.isExpanded;
        this.updateButton(rowName, isExpanded);
    }

    toggleRow(rowId) {
        const currentIndex = this.expandedRows.indexOf(rowId);
        if (currentIndex > -1) {
            // La ligne est développée, on la réduit
            this.expandedRows = this.expandedRows.filter(id => id !== rowId);
            this.updateButton(rowId, false);
        } else {
            // La ligne est réduite, on la développe
            this.expandedRows = [...this.expandedRows, rowId];
            this.updateButton(rowId, true);
        }
    }

    updateButton(rowId, isExpanded) {
        const updateButtonRecursively = (items) => {
            items.forEach(item => {
                if (item.id === rowId && item._children) {
                    if (isExpanded) {
                        // Ligne déroulée : icône chevrondown
                        item.buttonIcon = 'utility:opened_folder';
                        item.buttonVariant = 'brand';
                    } else {
                        // Ligne enroulée : icône chevronright
                        item.buttonIcon = 'utility:open_folder';
                        item.buttonVariant = 'neutral';
                    }
                }
                if (!item._children || item._children.length === 0) {
                    item.buttonIcon = '';
                    item.buttonVariant = 'neutral';
                }
                if (item._children) {
                    updateButtonRecursively(item._children);
                }
            });
        };

        const newData = [...this.treeData];
        updateButtonRecursively(newData);
        this.treeData = newData;
    }
}