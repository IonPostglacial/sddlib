package sdd;

import haxe.Exception;

using Lambda;
using sdd.XmlExtensions;

@:structInit
class TaxonHierarchy {
    public var taxon: Taxon;
    public var childrenHierarchyIds: Array<String>;
}

@:keep
@:expose
class Loader {
    public function new() {}

    function loadDataset(datasetElement: Xml): Dataset {
        final mediaObjectsById = loadMediaObjects(datasetElement);
        final charactersById = loadDatasetCharacters(datasetElement, mediaObjectsById);

        return {
            taxonsById: loadDatasetTaxons(datasetElement, mediaObjectsById, charactersById),
            charactersById: charactersById
        };
    }

    function loadMediaObjects(datasetElement: Xml): Map<String, MediaObject> {
        final mediaObjectsElement = datasetElement.firstElementNamed("MediaObjects");
        final mediaObjectsById: Map<String, MediaObject> = [];

        if (mediaObjectsElement == null ) return mediaObjectsById;

        for (mediaObjectElement in mediaObjectsElement.elementsNamed("MediaObject")) {
            final sourceElement = mediaObjectElement.firstElementNamed("Source");

            if (sourceElement != null) {
                final id = mediaObjectElement.get("id");
                final representation = loadRepresentation(mediaObjectElement.firstElementNamed("Representation"), mediaObjectsById);

                if (id == null) throw new Exception("Invalid SDD: a MediaObject declaration misses its 'id'.");

                mediaObjectsById.set(mediaObjectElement.get("id"), { source: sourceElement.get("href"), detail: representation.detail });
            }
        }

        return mediaObjectsById;
    }

    function loadRepresentation(representationElement: Xml, mediaObjectsByRef: Map<String, MediaObject>): Representation {
        if (representationElement == null) return { mediaObjects: [], label: "", detail: "" };

        final mediaObjects = [];

        for (mediaObjectElement in representationElement.elementsNamed("MediaObject")) {
            final mediaObject = mediaObjectsByRef[mediaObjectElement.get("ref")];
            if (mediaObject != null) {
                mediaObjects.push(mediaObject);
            }
        }
        final labelNode = representationElement.firstElementNamed("Label");
        final detailElement = representationElement.firstElementNamed("Detail");

        return {
            label: if (labelNode != null) { labelNode.innerText(); } else { "_"; },
            detail: if (detailElement != null) { detailElement.innerText(); } else { "_"; },
            mediaObjects: mediaObjects
        };
    }

    static inline function assertNotNull<T>(value: Null<T>, errorMessage: String): T {
        if (value == null) throw new Exception(errorMessage);
        return value;
    }

    function loadDatasetTaxons(datasetElement: Xml, mediaObjectsById: Map<String, MediaObject>, charactersById: Map<String, Character>): Map<String, Taxon> {
        final taxonsById: Map<String, Taxon> = [];
        final taxonNamesElement = datasetElement.firstElementNamed("TaxonNames");

        if (taxonNamesElement == null) return taxonsById;

        for (taxonElement in taxonNamesElement.elementsNamed("TaxonName")) {
            final taxonId = assertNotNull(taxonElement.get("id"), "Invalid SDD: a Taxon is missing its 'id'.");

            taxonsById.set(taxonId, new Taxon(taxonId, loadRepresentation(taxonElement.firstElementNamed("Representation"), mediaObjectsById)));
        }

        final codedDescriptionsElement = datasetElement.firstElementNamed("CodedDescriptions");

        if (codedDescriptionsElement != null) {
            for (codedDescriptionElement in codedDescriptionsElement.elementsNamed("CodedDescription")) {
                final scopeElement = assertNotNull(codedDescriptionElement.firstElementNamed("Scope"),
                    "Invalid SDD: a CodedDescription is missing its 'Scope'.");
                final taxonNameElement = assertNotNull(scopeElement.firstElementNamed("TaxonName"), 
                    "A CodedDescription Scope doesn't have a 'Taxon' element, which is the only one supported by this loader.");
                final taxonId = assertNotNull(taxonNameElement.get("ref"),
                    "Invalid SDD: a TaxonName is missing its 'ref'.");
                final representation = loadRepresentation(codedDescriptionElement.firstElementNamed("Representation"), mediaObjectsById);
                final taxonToAugment = assertNotNull(taxonsById.get(taxonId),
                    "Scope > TaxonName references a missing Taxon: " + taxonId);
                Representation.assign(taxonToAugment, representation);

                final summaryDataElement = codedDescriptionElement.firstElementNamed("SummaryData");

                if (summaryDataElement != null) {
                    final categoricalElements = summaryDataElement.elementsNamed("Categorical");

                    for (categoricalElement in categoricalElements) {
                        final characterId = assertNotNull(categoricalElement.get("ref"),
                            "Invalid SDD: a Categorical is missing its 'ref' attribute.");
                        final referencedCharacter = assertNotNull(charactersById.get(characterId),
                            "Invalid SDD: Categorical references a missing Character: " + characterId);
                        final states = [];
                        taxonToAugment.statesByCharacterId.set(characterId, states);
                        for (stateElement in categoricalElement.elementsNamed("State")) {
                            final stateId = assertNotNull(stateElement.get("ref"),
                                "Invalid SDD: a State is missing its 'ref'.");
                            final referencedState = assertNotNull(referencedCharacter.states.find(s -> s.id == stateId),
                                "Categorical > State references a missing State: " + stateId);
                            states.push(referencedState.copy());
                        }
                    }
                }
            }
        }

        final taxonHierarchiesElement = datasetElement.firstElementNamed("TaxonHierarchies");
        final taxonHierarchyElement = if (taxonHierarchiesElement != null) { taxonHierarchiesElement.firstElementNamed("TaxonHierarchy"); } else { null; }
        final nodesElement = if (taxonHierarchyElement != null) { taxonHierarchyElement.firstElementNamed("Nodes"); } else { null; }
        
        if (nodesElement != null) {
            final hierarchiesById: Map<String, TaxonHierarchy> = [];

            for (nodeElement in nodesElement.elementsNamed("Node")) {
                final hierarchyId = assertNotNull(nodeElement.get("id"),
                    "Invalid SDD: a TaxonHierarchy > Nodes > Node is missing its 'id'.");
                final taxonNameElement = assertNotNull(nodeElement.firstElementNamed("TaxonName"),
                    "Invalid SDD: a TaxonHierarchy > Nodes > Node is missing its 'TaxonName'.");
                final taxonId = assertNotNull(taxonNameElement.get("ref"),
                    "Invalid SDD: a TaxonHierarchy > Nodes > Node > TaxonName is missing its 'ref'.");
                final taxon = assertNotNull(taxonsById.get(taxonId),
                    "Invalid SDD: a TaxonHierarchy > Nodes > Node > TaxonName is referencing a missing Taxons: " + taxonId);
                var hierarchy = hierarchiesById.get(hierarchyId);
                
                if (hierarchy == null) {
                    hierarchy = { taxon:  taxon, childrenHierarchyIds: [] };
                } else {
                    hierarchy.taxon = taxon;
                }
                hierarchiesById.set(hierarchyId, hierarchy);

                final parentElement = nodeElement.firstElementNamed("Parent");

                if (parentElement != null) {
                    final parentId = assertNotNull(parentElement.get("ref"),
                        "Invalid SDD: a TaxonHierarchy >> Parent is missing its 'ref'.");
                    var parent = hierarchiesById.get(parentId);
                    if (parent == null) {
                        parent = { taxon: null, childrenHierarchyIds: [hierarchyId] };
                        hierarchiesById.set(parentId, parent);
                    } else {
                        parent.childrenHierarchyIds.push(hierarchyId);
                    }
                }
            }
            for (hierarchy in hierarchiesById) {
                final augmentedTaxon = hierarchy.taxon;

                for (hid in hierarchy.childrenHierarchyIds) {
                    final child = hierarchiesById.get(hid).taxon;
                    augmentedTaxon.children.push(child);
                }
            }
        }

        return taxonsById;
    }

    function loadDatasetCharacters(datasetElement: Xml, mediaObjectsById: Map<String, MediaObject>): Map<String, Character> {
        final charactersById: Map<String, Character> = [];
        final charactersElements = datasetElement.firstElementNamed("Characters");
        final statesById: Map<String, State> = [];

        if (charactersElements == null) return charactersById;

        for (characterElement in charactersElements.elements()) {
            if (characterElement.nodeName != "CategoricalCharacter" && characterElement.nodeName != "QuantitativeCharacter") {
                continue;
            }
            final characterId = assertNotNull(characterElement.get("id"), "Invalid SDD: a Character is missing its 'id'.");

            final statesElement = characterElement.firstElementNamed("States");

            final states = [];

            if (statesElement != null) {
                for (stateElement in statesElement.elementsNamed("StateDefinition")) {
                    final stateId = assertNotNull(stateElement.get("id"), "Invalid SDD: a State is missing its 'id'");
                    final state = new State(stateId, characterId, loadRepresentation(stateElement.firstElementNamed("Representation"), mediaObjectsById));
                    statesById.set(stateId, state);
                    states.push(state);
                }
            }

            charactersById.set(characterId, new Character(characterId, loadRepresentation(characterElement.firstElementNamed("Representation"), mediaObjectsById), states));

            final characterTreesElement = datasetElement.firstElementNamed("CharacterTrees");

            if (characterTreesElement != null) {
                for (characterTreeElement in characterTreesElement.elementsNamed("CharacterTrees")) {
                    final nodesElement = characterTreeElement.firstElementNamed("Nodes");

                    if (nodesElement != null) {
                        for (charNodeElement in nodesElement.elementsNamed("CharNode")) {
                            final characterElement = assertNotNull(charNodeElement.firstElementNamed("Character"),
                                "Invalid SDD: a CharNode is missing its 'Character'.");
                            final characterRef = assertNotNull(characterElement.get("ref"),
                                "Invalid SDD: a CharNode > Character is missing its 'ref.");
                            final augmentedCharacter = assertNotNull(charactersById.get(characterRef),
                                "Invalid SDD: a CharNode > Character references a missing Character: " + characterRef);
                            final dependencyRulesElement = charNodeElement.firstElementNamed("DependencyRules");

                            if (dependencyRulesElement != null) {
                                final inapplicableIfElement = dependencyRulesElement.firstElementNamed("InapplicableIf");

                                if (inapplicableIfElement != null) {
                                    for (stateElement in inapplicableIfElement.elementsNamed("State")) {
                                        final stateRef = assertNotNull(stateElement.get("ref"),
                                            "Invalid SDD: an InapplicableIf > State is missing its 'ref'.");
                                        final state = assertNotNull(statesById.get(stateRef),
                                            "Invalid SDD: an InapplicableIf > State references a missing State: " + stateRef);
                                        augmentedCharacter.inapplicableStates.push(state);
                                        augmentedCharacter.parentId = state.characterId;
                                    }
                                }
                            }
                            if (augmentedCharacter.inapplicableStates.length > 0) {
                                charactersById.get(augmentedCharacter.parentId).children.push(augmentedCharacter);
                            }
                        }
                    }
                }
            }
        }
        return charactersById;
    }

    public function load(text: String): Array<Dataset> {
        final xml = Xml.parse(text);
        final datasetsElements = xml.firstElement();
        final datasets = [];

        for (datasetElement in datasetsElements) {
            datasets.push(loadDataset(datasetElement));
        }

        return datasets;
    }
}