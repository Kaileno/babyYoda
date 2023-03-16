import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getOpenCaseRecords from '@salesforce/apex/casosInterplanetariosService.getOpenCaseRecords';
import isGroguOnPlanet from '@salesforce/apex/casosInterplanetariosService.isGroguOnPlanet';

const columns = [
    {label: 'Asunto', fieldName: 'subject', type:"text"},
    {label: 'Estado', fieldName: 'status', type:"text"},
    {label: 'Email de Contacto', fieldName: 'email', type:"email"},
    {label: 'Contacto Relacionado', fieldName: 'contactURL', type:"url"}
];

export default class CasosInterplanetarios extends LightningElement {
    data = [];
    columns = columns;
    subscription = {};
    CHANNEL_NAME = '/event/RefreshCaseList__e';

    connectedCallback() {
        this.getRecords();
        subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
    }

    refreshList = ()=> {
        this.isLoading = true;
        this.getRecords();
    }

    getRecords(){
        const data = getOpenCaseRecords()
        .then(response => {
            debugger;
            this._jsonResponse = response;
            if (response) {
                let jsonData= JSON.parse(response);
                console.log(jsonData);
                this.data = jsonData;
            }
        })
        .catch(error => {
                this.error = error;
        });
    }


}