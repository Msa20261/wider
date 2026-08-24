# Guide de test manuel — Attribution automatique des tâches CRM (demande #9)

> Chantier réalisé le 2026-08-24 sur `wider-test`, en réponse au besoin d'Ana
> (briefing "5.1 Nouvelle opportunité et attribution", p.9) : pouvoir attribuer
> une tâche à n'importe quel Contact, et laisser Salesforce déterminer
> automatiquement le bon "Assign To" (`OwnerId`), y compris pour le contact
> Triviso "Manque resp ou à définir".

## Résumé des 5 étapes réalisées

**Étape 1 — FLS du champ technique.** Le champ `Contact.Utilisateur_Salesforce__c` (un lookup vers User) avait déjà été créé lors d'une session précédente, mais il était invisible car aucun profil courant n'avait le droit de le lire. On a créé le Permission Set `PS_Utilisateur_SF_Technique` pour le rendre accessible.

**Étape 2 — Queue de repli.** Création de la Queue "Tâches non attribuées", avec pour membres Ana Leal, Toni Cortes, Alexandre Gilbert, Admin Francois et toi. C'est là que tombent les tâches dont le contact n'a pas de correspondance côté utilisateurs Salesforce.

**Étape 3 — Rapprochement Contact ↔ User.** Le champ `Utilisateur_Salesforce__c` a été rempli pour les trois collaborateurs internes Wider qui ont à la fois une fiche Contact et un compte User : Ana Leal, Toni Cortes et Alexandre Gilbert. Les comptes admin Upmind ont volontairement été exclus, puisqu'ils ne sont pas des collaborateurs internes Wider.

**Étape 4 — Le Flow d'attribution.** Construction du Flow `Task_Attribution_Automatique`, qui s'exécute juste avant l'enregistrement de chaque tâche. Il est entièrement dynamique : aucune valeur (comme l'identifiant de la Queue) n'est codée en dur, ce qui le rend déployable tel quel sur n'importe quelle org.

**Étape 5 — Tests et activation.** Le Flow a été testé sur six scénarios différents (via Apex avec annulation automatique, donc sans laisser de fausses données), puis activé pour de vrai sur `wider-test`.

Concrètement, voici ce qui se passe maintenant : dès qu'on renseigne le champ Contact sur une tâche, "Assign To" se remplit tout seul. Si ce contact correspond à un collaborateur interne (Ana, Toni ou Gilbert), la tâche lui est attribuée directement et apparaît dans ses tâches Salesforce. Si le contact est externe, ou que c'est "Manque resp ou à définir", la tâche part dans la Queue "Tâches non attribuées". Et si quelqu'un réattribue une tâche à la main, cette réattribution n'est jamais écrasée tant que le contact de la tâche ne change pas.

## Cas de test à essayer toi-même dans l'org

Pour chaque cas, le principe est le même : tu crées une tâche via le bouton "Nouvelle tâche" dans le panneau Activités, tu renseignes le champ Contact, tu enregistres, puis tu rouvres la tâche pour regarder ce qu'il y a dans "Assign To".

D'abord, essaie de créer une tâche en choisissant Ana Leal, Toni Cortes ou Alexandre Gilbert comme contact : "Assign To" doit se remplir automatiquement avec le User correspondant, pas avec toi ni avec le créateur de la tâche.

Ensuite, crée une tâche en choisissant le contact "Manque resp ou à définir" : "Assign To" doit basculer sur la Queue "Tâches non attribuées". Fais le même essai avec un contact externe classique, comme un architecte ou un maître d'ouvrage : le résultat doit être identique, la Queue.

Prends ensuite la tâche que tu viens de créer avec "Manque resp ou à définir", et modifie son contact pour le remplacer par Ana Leal, puis enregistre : "Assign To" doit basculer automatiquement sur Ana Leal, preuve que le Flow réagit bien à un changement de contact et pas seulement à la création.

Teste aussi la protection contre l'écrasement : crée une tâche avec Ana Leal comme contact, puis une fois enregistrée, change manuellement "Assign To" pour le mettre sur Toni Cortes sans toucher au contact, et enregistre. Modifie ensuite un champ sans rapport, comme la description, et enregistre à nouveau : "Assign To" doit rester sur Toni Cortes, ta réattribution manuelle ne doit pas avoir été écrasée par le Flow.

Enfin, crée une tâche sans renseigner aucun contact : "Assign To" doit rester sur toi, comme avant, puisque le Flow ne se déclenche que lorsqu'un contact est présent.

Pour vérifier le cas des collaborateurs internes, le plus simple est de demander à Ana de regarder sa liste "Mes tâches" et de confirmer que la tâche y apparaît bien. Pour vérifier les cas qui tombent dans la Queue, la tâche ne sera plus dans "Mes tâches" du créateur ; tu peux la retrouver en ouvrant directement la tâche et en regardant son propriétaire, ou via un rapport filtré sur ce champ.

## En cas de problème

Si un des cas ne donne pas le résultat attendu, dis-moi lequel, le nom exact du contact utilisé, et ce que tu observes sur "Assign To" — je comparerai avec les résultats de test déjà obtenus (entrée #9 de `HISTORIQUE-DEMANDES-WIDER.md`) pour comprendre ce qui diverge.
