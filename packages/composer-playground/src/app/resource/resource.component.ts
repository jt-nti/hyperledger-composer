import { Component, OnInit, Input } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';
import { ClientService } from '../services/client.service';
import { InitializationService } from '../services/initialization.service';
import {
    ClassDeclaration,
    AssetDeclaration,
    ParticipantDeclaration,
    TransactionDeclaration
} from 'composer-common';
import {
    FormControl,
    FormGroup,
    FormArray,
    Validators,
    FormBuilder
} from '@angular/forms';
import leftPad = require('left-pad');

import 'codemirror/mode/javascript/javascript';
import 'codemirror/addon/fold/foldcode';
import 'codemirror/addon/fold/foldgutter';
import 'codemirror/addon/fold/brace-fold';
import 'codemirror/addon/fold/comment-fold';
import 'codemirror/addon/fold/markdown-fold';
import 'codemirror/addon/fold/xml-fold';
import 'codemirror/addon/scroll/simplescrollbars';

@Component({
    selector: 'resource-modal',
    templateUrl: './resource.component.html',
    styleUrls: ['./resource.component.scss'.toString()]
})

export class ResourceComponent implements OnInit {

    @Input() registryID: string;
    @Input() resource: any = null;
    private resourceProperties: any = [];
    private resourceForm: FormGroup = this.fb.group({$class:['']});
    private resourceAction: string = null;
    private resourceType: string = null;
    private resourceDefinition: string = null;
    private resourceDeclaration: ClassDeclaration = null;
    private resourceClass: string = '';
    private actionInProgress: boolean = false;
    private definitionError: string = null;
    private complexDataStructure: boolean = false;

    private codeConfig = {
        lineNumbers: true,
        lineWrapping: false,
        readOnly: false,
        mode: 'javascript',
        autofocus: true,
        extraKeys: {
            'Ctrl-Q': (cm) => {
                cm.foldCode(cm.getCursor());
            }
        },
        foldGutter: true,
        gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
        scrollbarStyle: 'simple'
    };

    constructor(public activeModal: NgbActiveModal,
                private clientService: ClientService,
                private initializationService: InitializationService,
                private fb: FormBuilder) {
    }

    ngOnInit(): Promise<any> {
        return this.initializationService.initialize()
        .then(() => {

            // Determine what resource declaration we are using and stub json decription
            let introspector = this.clientService.getBusinessNetwork().getIntrospector();
            let modelClassDeclarations = introspector.getClassDeclarations();
            console.log('modelClassDeclarations is',modelClassDeclarations)

            modelClassDeclarations.forEach((modelClassDeclaration) => {
                if(this.registryID === modelClassDeclaration.getFullyQualifiedName()) {
                    // Set resource declaration
                    this.resourceDeclaration = modelClassDeclaration;
                    this.resourceType = this.retrieveResourceType(modelClassDeclaration);
                    this.resourceProperties = this.resourceDeclaration.getProperties();
                    console.log('this.resourceProperties',this.resourceProperties);

                    this.resourceClass = this.resourceDeclaration.getFullyQualifiedName();
                    let tempForm = this.fb.group({$class: [this.resourceClass]});

                    for(let x=0;x<this.resourceProperties.length;x++){
                        if(this.resourceProperties[x].isArray()){
                            // Too complex to handle. Handling arrays in forms won't end well..
                            this.complexDataStructure = true;
                        } else{
                            // We can attempt to handle this.
                            let tempFormControl;
                            let addedControl:boolean = false;
                            let subFormGroup;
                            this.complexDataStructure = false;

                            if(this.resourceProperties[x].isTypeEnum()){
                                modelClassDeclarations.forEach((classDec) => {
                                    if(this.resourceProperties[x].type === classDec.name){
                                        this.resourceProperties[x]['options'] = classDec.getProperties();
                                    }
                                });
                            } else{
                                modelClassDeclarations.forEach((classDec) => {

                                    if(this.resourceProperties[x].type === classDec.name){
                                        let canContinue:boolean = true;
                                        if(classDec.abstract === true){
                                            console.log('Class dec is abstract');
                                            let assignableClassDeclarationsList = classDec.getAssignableClassDeclarations();
                                            if(assignableClassDeclarationsList.length > 2){
                                                // We can't handle this. Add error in here.
                                                canContinue = false;
                                                this.complexDataStructure = true;
                                                addedControl = true;
                                            } else{
                                                console.log('assignableClassDeclarationsList.length < 2')
                                                this.complexDataStructure = false;
                                                let allProperties = [];
                                                for(let i=0;i<assignableClassDeclarationsList.length;i++){
                                                    if(assignableClassDeclarationsList[i].superType == classDec.name){
                                                        console.log('Found a super type for', assignableClassDeclarationsList[i].name)
                                                        classDec = assignableClassDeclarationsList[i];
                                                        console.log('What is classDec?',classDec.name)
                                                        let extendedProperties = classDec.getOwnProperties();
                                                        extendedProperties.forEach((property) => {
                                                            allProperties.push(property);
                                                        });
                                                    } else{
                                                        let abstractProperties = assignableClassDeclarationsList[i].getOwnProperties();
                                                        abstractProperties.forEach((property) => {
                                                            allProperties.push(property);
                                                        });
                                                    }
                                                }

                                                console.log('All properties..',allProperties);
                                                subFormGroup = this.fb.group({$class:[classDec.getFullyQualifiedName()]});
                                                this.resourceProperties[x]['nestedOptions'] = allProperties;
                                                this.resourceProperties[x]['nestedOptions'].forEach((option) => {
                                                    if(option.optional === false){
                                                        tempFormControl = new FormControl('', Validators.required);
                                                    } else{
                                                        tempFormControl = new FormControl('');
                                                    }
                                                    subFormGroup.addControl(option.name,tempFormControl);

                                                });
                                                tempForm.addControl(this.resourceProperties[x].name,subFormGroup);
                                                addedControl = true;

                                                // We now want to get the abstract properties and extended properties of our
                                                // newly retrieved class declaration.
                                                // We need to get the class name also
                                                // We should then create the form controles here and set addedControl = true
                                            }

                                        }
                                        // Do if check here to see if we can continue, if not set this.complexDataStructure = true
                                        // Wrap everything below inside statement
                                        if(canContinue){
                                            if(classDec.ast.type === 'ConceptDeclaration'){
                                                console.log('canContinue is true, fqn is:',classDec.getFullyQualifiedName());
                                                subFormGroup = this.fb.group({$class:[classDec.getFullyQualifiedName()]});
                                                this.resourceProperties[x]['nestedOptions'] = classDec.getProperties();
                                                this.resourceProperties[x]['nestedOptions'].forEach((option) => {
                                                    if(option.optional === false){
                                                        tempFormControl = new FormControl('', Validators.required);
                                                    } else{
                                                        tempFormControl = new FormControl('');
                                                    }
                                                    subFormGroup.addControl(option.name,tempFormControl);

                                                });
                                                tempForm.addControl(this.resourceProperties[x].name,subFormGroup);
                                                addedControl = true;
                                            }
                                        }
                                    }
                                });
                            }
                            if(!addedControl){
                                if(this.resourceProperties[x].optional === false){
                                    tempFormControl = new FormControl('', Validators.required);
                                } else{
                                    tempFormControl = new FormControl('');
                                }

                                if(this.resourceProperties[x].type){
                                    tempForm.addControl(this.resourceProperties[x].name, tempFormControl);
                                }
                            }
                        }
                    }

                    if (this.editMode()) {
                        this.resourceAction = 'Update';
                        let serializer = this.clientService.getBusinessNetwork().getSerializer();
                        this.resourceDefinition = JSON.stringify(serializer.toJSON(this.resource), null, 2);
                    } else {
                        // Stub out json definition
                        this.resourceAction = 'Create New';
                        this.generateResource();
                    }

                    if(!this.complexDataStructure){
                        this.resourceForm = tempForm;
                        console.log('Form built', this.resourceForm.value);
                        this.resourceDefinition = JSON.stringify(this.resourceForm.value, null, 2);
                        this.onDefinitionChanged();
                        this.resourceForm.valueChanges.subscribe((data) => {
                            try {
                                this.definitionError = null;
                                let serializer = this.clientService.getBusinessNetwork().getSerializer();
                                if(this.resourceDefinition !== data){
                                    this.resourceDefinition = JSON.stringify(data, null, 2);
                                }
                                let resource = serializer.fromJSON(data);
                                resource.validate();
                            } catch(error) {
                                this.definitionError = error.toString();
                            }
                        });
                    }
                }
            });
        });
    }

    /**
     * Validate json definition of resource
     */
    onDefinitionChanged() {
        try {
            this.definitionError = null;
            let json = JSON.parse(this.resourceDefinition);
            let serializer = this.clientService.getBusinessNetwork().getSerializer();
            if(!this.complexDataStructure){
                if(this.resourceForm.value !== json){
                    this.resourceForm.setValue(json);
                }
            }
            let resource = serializer.fromJSON(json);
            resource.validate();
        } catch(error) {
            this.definitionError = error.toString();
        }
    }

    private editMode(): boolean {
        return (this.resource ? true : false);
    }

    /**
     * Generate the json description of a resource
     */
    private generateResource(withSampleData?: boolean): void {
        let businessNetworkDefinition = this.clientService.getBusinessNetwork();
        let factory = businessNetworkDefinition.getFactory();
        let idx = Math.round(Math.random() * 9999).toString();
        idx = leftPad(idx, 4, '0');
        let id = `${this.resourceDeclaration.getIdentifierFieldName()}:${idx}`;
        try {
            const generateParameters = {generate: withSampleData ? 'sample' : 'empty'};
            let resource = factory.newResource(
                this.resourceDeclaration.getModelFile().getNamespace(),
                this.resourceDeclaration.getName(),
                id,
                generateParameters);
            let serializer = this.clientService.getBusinessNetwork().getSerializer();
            let json = serializer.toJSON(resource);
            this.resourceDefinition = JSON.stringify(json, null, 2);
            this.onDefinitionChanged();
        } catch(error) {
            // We can't generate a sample instance for some reason.
            this.definitionError = error.toString();
            this.resourceDefinition = '';
        }
    }

    /**
     *  Create resource via json serialisation
     */
    private addOrUpdateResource(): void {
        this.actionInProgress = true;
        return this.retrieveResourceRegistry(this.resourceType)
        .then((registry) => {
            let json = JSON.parse(this.resourceDefinition);
            let serializer = this.clientService.getBusinessNetwork().getSerializer();
            let resource = serializer.fromJSON(json);
            resource.validate();
            if (this.editMode()) {
                return registry.update(resource);
            } else {
                return registry.add(resource);
            }
        })
        .then(() => {
            this.actionInProgress = false;
            this.activeModal.close();
        })
        .catch((error) => {
            this.definitionError = error.toString();
            this.actionInProgress = false;
        });
    }

    /**
     * Retrieve string description of resource type instance
     */
    private retrieveResourceType(modelClassDeclaration): string {
        if (modelClassDeclaration instanceof TransactionDeclaration) {
            return 'Transaction';
        } else if (modelClassDeclaration instanceof AssetDeclaration) {
            return 'Asset';
        } else if (modelClassDeclaration instanceof ParticipantDeclaration) {
            return 'Participant';
        }
    }

    /**
     * Retrieve a ResourceRegistry for the passed string resource type instance
     */
    private retrieveResourceRegistry(type) {

        let client = this.clientService;
        let id = this.registryID;

        function isAsset() {
            return client.getBusinessNetworkConnection().getAssetRegistry(id);
        }

        function isTransaction() {
            return client.getBusinessNetworkConnection().getTransactionRegistry();
        }

        function isParticipant() {
            return client.getBusinessNetworkConnection().getParticipantRegistry(id);
        }

        let types = {
            Asset: isAsset,
            Participant: isParticipant,
            Transaction: isTransaction
        };

        return types[type]();

    }

    private onSubmit(){
        console.log('Form submitted with',this.resourceForm.value);
    }

}
