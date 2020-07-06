package sdd;

import haxe.xml.Access;

class Saver {
    public var datasets: Array<Dataset>;
    public var mediaObjectsCount = 0;
    
    public function new(datasets: Array<Dataset>) {
        this.datasets = datasets;
    }
        
    function createRepresentation(root: Xml, representation: Representation): Xml {
        final mediaObjects = if (representation.mediaObjects.length > 0) {
            final xml = Xml.createElement("MediaObjects");
            for (mediaObject in representation.mediaObjects) {
                xml.addChild(createMediaObject(new Access(root), mediaObject));
            }
            xml.toString();
        } else {
            "";
        };
        final representation = Xml.parse('
            <Representation>
                <Label>${representation.label}</Label>
                <Detail>${representation.label}</Detail>
                $mediaObjects
            </Representation>');
        return representation;
    }

    function createMediaObject(root: Access, mediaObject: MediaObject): Xml {
        mediaObjectsCount++;
        final id = "m" + mediaObjectsCount;
        final mediaObjectElement = Xml.parse('
            <MediaObject id="$id">
                <Source href="${mediaObject.source}" />
                <Type>Image</Type>
                <Representation>
                    <Label>${mediaObject.label}</Label>
                    <Detail role="Caption">${mediaObject.detail}</Detail>
                </Representation>
            </MediaObject>');
        root.node.MediaObjects.x.addChild(mediaObjectElement);

        return Xml.parse('MediaObject ref="$id"');
    }

    function createTaxonName(root: Xml, taxon: Taxon): Xml {
        final representation = createRepresentation(root, taxon).toString();
        return Xml.parse('
            <TaxonName id="${taxon.id}">
                $representation
            </TaxonName');
    }

    function createTaxonHierarchyNode(taxon: Taxon, taxonsById: Map<String, Taxon>): Xml {
        final parentHid = if (taxon.parentId == null) "" else taxonsById.get(taxon.parentId).hid;
        return Xml.parse('
            <Node id="${taxon.hid}">
                <Parent ref="$parentHid" />
                <TaxonName ref="${taxon.id}" />
            </Node>');
    }

    function createStateNode(root: Xml, state: State): Xml {
        final representation = createRepresentation(root, state);
        return Xml.parse('
            <StateDefinition id="${state.id}">
                $representation
            </StateDefinition>');
    }

    function createCharacterNode(root: Xml, character: Character, statesById: Map<String, State>): Xml {
        final representation = createRepresentation(root, character).toString();
        return Xml.parse('
            <CategoricalCharacter id="${character.id}">
                $representation
                ' + if (character.statesIds.length > 0)
                    '<States>${ character.statesIds.map(id -> createStateNode(root, statesById.get(id))) }</States>'
                else '' +
            '</CategoricalCharacter>');
    }

    function createDataset(dataset: Dataset): Xml {
        final datasetNode = Xml.parse('
        <Dataset xmlns="" xml:lang="fr">
            <TechnicalMetadata created="2020-06-23T20:34:56.012Z">
                <Generator name="Bunga" notes="This software is developed and distributed by Li Tian &amp; Nicolas Galipot - Copyright (c) 2020" version="0.9" />
            </TechnicalMetadata>
            <Representation>
                <Label>Sample</Label>
            </Representation>
            <TaxonNames></TaxonNames>
            <TaxonHierarchies>
                <TaxonHierarchy id="th1">
                    <Representation>
                        <Label>Default Entity Tree</Label>
                    </Representation>
                    <TaxonHierarchyType>UnspecifiedTaxonomy</TaxonHierarchyType>
                    <Nodes>
                    </Nodes>
                </TaxonHierarchy>
            </TaxonHierarchies>
            <Characters></Characters>
            <CharacterTrees></CharacterTrees>
            <CodedDescriptions></CodedDescriptions>
            <MediaObjects></MediaObjects>
        </Dataset>
        ');
        final datasetAccess = new Access(datasetNode);
        final taxonNamesXml = datasetAccess.node.TaxonNames.x;
        final taxonHierarchyNodesXml = datasetAccess.node.TaxonHierarchies.node.TaxonHierarchy.node.Nodes.x;
        final charactersXml = datasetAccess.node.Characters.x;
        final characterTreesXml = datasetAccess.node.CharacterTrees.x;

        final taxonsById: Map<String, Taxon> = [];
        final statesById = [for (state in dataset.states) state.id => state];

        for (taxon in dataset.taxons) {
            taxonsById.set(taxon.id, taxon);
            taxonNamesXml.addChild(createTaxonName(datasetNode, taxon));
        }

        for (taxon in dataset.taxons) {
            taxonHierarchyNodesXml.addChild(createTaxonHierarchyNode(taxon, taxonsById));
        }

        // TODO: implement DescriptiveConcepts

        for (character in dataset.characters) {
            charactersXml.addChild(createCharacterNode(datasetNode, character, statesById));
        }
        
        // Character Trees
    
        // final characterTrees = Xml.createElement("CharacterTrees");
        
        // final characterTree = Xml.createElement("CharacterTree");
        // characterTree.set("id", "ct1");
        // characterTree.addChild(createRepresentation(xml, { name: "Ordre et dependance entre caracteres" }));
        // characterTree.addChild(Object.assign(Xml.createElement("ShouldContainAllCharacters"), { textContent: "true" }));
        // final charTreeNodes = Xml.createElement("Nodes");
        // characterTree.addChild(charTreeNodes);
        
        // final characterTreeConcepts = Xml.createElement("CharacterTree");
        // characterTreeConcepts.set("id", "ct2");
        // characterTreeConcepts.addChild(createRepresentation(xml, { name: "Arbre secondaire Xper2 : groupes et variables contenues dans ces groupes" }));
        // final charTreeConceptsNodes = Xml.createElement("Nodes");
        // characterTreeConcepts.addChild(charTreeConceptsNodes);
    
        // (function addDescriptorHierarchyNodes (hierarchy, nodesElement, parentRef) {
        //     for (descriptorHierarchy in Object.values(hierarchy)) {
        //         var node;
        //         if (descriptorHierarchy.type == "concept") {
        //             final descriptiveConcept = node = Xml.createElement("DescriptiveConcept");
        //             descriptiveConcept.set("id", descriptorHierarchy.id);
        //             descriptiveConcept.addChild(createRepresentation(xml, descriptorHierarchy));
        //             descriptiveConcepts.addChild(descriptiveConcept);
    
        //             final descriptiveConceptElement = Xml.createElement("DescriptiveConcept");
        //             descriptiveConceptElement.set("ref", descriptorHierarchy.id);
    
        //             final nodeElement = Xml.createElement("Node");
        //             nodeElement.set("id", descriptorHierarchy.hid);
        //             nodeElement.addChild(descriptiveConceptElement);
    
        //             charTreeConceptsNodes.addChild(nodeElement);
                        
        //             addDescriptorHierarchyNodes(descriptorHierarchy.children, charTreeConceptsNodes, descriptorHierarchy.hid);
        //         } else if (descriptorHierarchy.type == "character") {
        //             final charNode = node = Xml.createElement("CharNode");
        //             final character = Xml.createElement("Character");
        //             character.set("ref", descriptorHierarchy.id);
                    
        //             final dependencyRules = Xml.createElement("DependencyRules");
        //             final inapplicableIf = Xml.createElement("InapplicableIf");
                    
        //             for (inapplicableState in descriptorHierarchy.inapplicableStates) {
        //                 final state = Xml.createElement("State");
        //                 state.set("ref", inapplicableState.id);
        //                 inapplicableIf.addChild(state);
        //             }
        //             if (inapplicableIf.children.length > 0) {
        //                 dependencyRules.addChild(inapplicableIf);
        //                 charNode.addChild(dependencyRules);
        //             }
        //             charNode.addChild(character);
        //             nodesElement.addChild(charNode);
        //         }
        //         if (parentRef != null) {
        //             final parent = Xml.createElement("Parent");
        //             parent.set("ref", parentRef);
        //             node.prepend(parent);
        //         }
        //     }
        // })(descriptors, charTreeNodes);
    
        // characterTrees.addChild(characterTree);
        // if (charTreeConceptsNodes.children.length > 0) {
        //     characterTrees.addChild(characterTreeConcepts);
        // }
        // dataset.addChild(characterTrees);
    
        // // Coded Descriptions
    
        // final codedDescriptions = Xml.createElement("CodedDescriptions");
        // var codedDescriptionsCount = 0;
    
        // dataset.addChild(codedDescriptions);
    
        // for (item in Object.values(items)) {
        //     codedDescriptionsCount++;
        //     final codedDescription = Xml.createElement("CodedDescription");
        //     final taxonName = Xml.createElement("TaxonName");
        //     final scope = Xml.createElement("Scope");
            
        //     taxonName.set("ref", item.id);
        //     scope.addChild(taxonName);
    
        //     codedDescription.set("id", "D" + codedDescriptionsCount);
        //     codedDescription.addChild(createRepresentation(xml, item));
        //     codedDescription.addChild(scope);
    
        //     final summaryData = Xml.createElement("SummaryData");
    
        //     for (description in item.descriptions) {
        //         final categorical = Xml.createElement("Categorical");
        //         categorical.set("ref", description.descriptor.id);
                
        //         final ratings = Xml.createElement("Ratings");
        //         final rating = Xml.createElement("Rating");
        //         rating.set("context", "ObservationConvenience");
        //         rating.set("rating", "Rating3of5");
    
        //         ratings.addChild(rating);
        //         categorical.addChild(ratings);
    
        //         for (state in description.states) {
        //             if (state == null) { continue; }
        //             final stateElement = Xml.createElement("State");
        //             stateElement.set("ref", state.id);
        //             categorical.addChild(stateElement);
        //         }
    
        //         summaryData.addChild(categorical);
        //     }
    
        //     codedDescription.addChild(summaryData);
    
        //     codedDescriptions.addChild(codedDescription);
        // }
        // dataset.addChild(mediaObjects);

        return datasetNode;
    }

    public function save(): String {
        final xml = Xml.parse('<?xml version="1.0" encoding="UTF-8"?>
        <Datasets xmlns="http://rs.tdwg.org/UBIF/2006/"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://rs.tdwg.org/UBIF/2006/Schema/1.1/SDD.xsd">
        </Datasets>');
        final root = xml.firstElement();
        
        for (dataset in datasets) {
            root.addChild(createDataset(dataset));
        }
    
        return xml.toString();
    }
}