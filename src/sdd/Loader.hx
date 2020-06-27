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
            taxons: loadDatasetTaxons(datasetElement, mediaObjectsById, charactersById).array(),
            characters: charactersById.array()
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
        if (representationElement == null) return { mediaObjects: [], name: "", detail: "" };

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
            name: if (labelNode != null) { labelNode.innerText(); } else { "_"; },
            detail: if (detailElement != null) { detailElement.innerText(); } else { "_"; },
            mediaObjects: mediaObjects
        };
    }

    static inline function assertNotNull<T>(value: Null<T>, exception: Exception): T {
        if (value == null) throw exception;
        return value;
    }

    function loadDatasetTaxons(datasetElement: Xml, mediaObjectsById: Map<String, MediaObject>, charactersById: Map<String, Character>): Map<String, Taxon> {
        final taxonsById: Map<String, Taxon> = [];
        final taxonNamesElement = datasetElement.firstElementNamed("TaxonNames");

        if (taxonNamesElement == null) return [];

        for (taxonElement in taxonNamesElement.elementsNamed("TaxonName")) {
            final taxonId = assertNotNull(taxonElement.get("id"), new SddException("A Taxon is missing its 'id'."));

            taxonsById.set(taxonId, new Taxon(taxonId, loadRepresentation(taxonElement.firstElementNamed("Representation"), mediaObjectsById)));
        }

        final codedDescriptionsElement = datasetElement.firstElementNamed("CodedDescriptions");

        if (codedDescriptionsElement != null) {
            for (codedDescriptionElement in codedDescriptionsElement.elementsNamed("CodedDescription")) {
                final scopeElement = assertNotNull(codedDescriptionElement.firstElementNamed("Scope"),
                    new SddException("A CodedDescription is missing its 'Scope'."));
                final taxonNameElement = assertNotNull(scopeElement.firstElementNamed("TaxonName"), 
                    new SddException("A CodedDescription Scope doesn't have a 'Taxon' element, which is the only one supported by this loader."));
                final taxonId = assertNotNull(taxonNameElement.get("ref"),
                    new SddException("A TaxonName is missing its 'ref'."));
                final representation = loadRepresentation(codedDescriptionElement.firstElementNamed("Representation"), mediaObjectsById);
                final taxonToAugment = assertNotNull(taxonsById.get(taxonId),
                    new SddRefException("Scope > TaxonName", "Taxon", taxonId));
                Representation.assign(taxonToAugment, representation);

                final summaryDataElement = codedDescriptionElement.firstElementNamed("SummaryData");

                if (summaryDataElement != null) {
                    final categoricalElements = summaryDataElement.elementsNamed("Categorical");

                    for (categoricalElement in categoricalElements) {
                        final characterId = assertNotNull(categoricalElement.get("ref"),
                            new SddException("A Categorical is missing its 'ref' attribute."));
                        final referencedCharacter = assertNotNull(charactersById.get(characterId),
                            new SddRefException("Categorical", "Character", characterId));
                        for (stateElement in categoricalElement.elementsNamed("State")) {
                            final stateId = assertNotNull(stateElement.get("ref"),
                                new SddException("A State is missing its 'ref'."));
                            final referencedState = assertNotNull(referencedCharacter.states.find(s -> s.id == stateId),
                                new SddRefException("Categorical > State", "State", stateId));
                            taxonToAugment.selectedStates.push(referencedState.copy());
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
                    new SddException("A TaxonHierarchy > Nodes > Node is missing its 'id'."));
                final taxonNameElement = assertNotNull(nodeElement.firstElementNamed("TaxonName"),
                new SddException("A TaxonHierarchy > Nodes > Node is missing its 'TaxonName'."));
                final taxonId = assertNotNull(taxonNameElement.get("ref"),
                    new SddException("A TaxonHierarchy > Nodes > Node > TaxonName is missing its 'ref'."));
                final taxon = assertNotNull(taxonsById.get(taxonId),
                    new SddRefException("TaxonHierarchy > Nodes > Node > TaxonName", "Taxons", taxonId));
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
                        new SddException("A TaxonHierarchy >> Parent is missing its 'ref'."));
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
                    child.parentId = augmentedTaxon.id;
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
            final characterId = assertNotNull(characterElement.get("id"), new SddException("A Character is missing its 'id'."));

            final statesElement = characterElement.firstElementNamed("States");

            final states = [];

            if (statesElement != null) {
                for (stateElement in statesElement.elementsNamed("StateDefinition")) {
                    final stateId = assertNotNull(stateElement.get("id"), new SddException("A State is missing its 'id'"));
                    final state = new State(stateId, characterId, loadRepresentation(stateElement.firstElementNamed("Representation"), mediaObjectsById));
                    statesById.set(stateId, state);
                    states.push(state);
                }
            }

            charactersById.set(characterId, new Character(characterId, loadRepresentation(characterElement.firstElementNamed("Representation"), mediaObjectsById), states));
        }
        final characterTreesElement = datasetElement.firstElementNamed("CharacterTrees");

        if (characterTreesElement != null) {
            for (characterTreeElement in characterTreesElement.elementsNamed("CharacterTree")) {
                final nodesElement = characterTreeElement.firstElementNamed("Nodes");

                if (nodesElement != null) {
                    for (charNodeElement in nodesElement.elementsNamed("CharNode")) {
                        final characterElement = assertNotNull(charNodeElement.firstElementNamed("Character"),
                            new SddException("A CharNode is missing its 'Character'."));
                        final characterRef = assertNotNull(characterElement.get("ref"),
                            new SddException("A CharNode > Character is missing its 'ref."));
                        final augmentedCharacter = assertNotNull(charactersById.get(characterRef),
                            new SddRefException("CharNode > Character", "Character", characterRef));
                        final dependencyRulesElement = charNodeElement.firstElementNamed("DependencyRules");

                        if (dependencyRulesElement != null) {
                            final inapplicableIfElement = dependencyRulesElement.firstElementNamed("InapplicableIf");

                            if (inapplicableIfElement != null) {
                                for (stateElement in inapplicableIfElement.elementsNamed("State")) {
                                    final stateRef = assertNotNull(stateElement.get("ref"),
                                        new SddException("A InapplicableIf > State is missing its 'ref'."));
                                    final state = assertNotNull(statesById.get(stateRef),
                                        new SddRefException("InapplicableIf > State", "State", stateRef));
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