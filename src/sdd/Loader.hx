package sdd;

import haxe.Exception;

using Lambda;
using sdd.XmlExtensions;

@:structInit class TaxonHierarchy {
	public var taxon:Taxon;
	public var childrenHierarchyIds:Array<String>;
}

@:structInit class CharactersAndStatesById {
	public var charactersById:Map<String, Character>;
	public var statesById:Map<String, State>;
}

@:keep
@:expose
class Loader {
	var strictMode:Bool;

	public var exceptionLog(default, null):Array<String> = [];

	public function new(?strictMode = true) {
		this.strictMode = strictMode;
	}

	function loadDataset(datasetElement:Xml):Dataset {
		final mediaObjectsById = loadMediaObjects(datasetElement);
		final charsAndStatesById = loadDatasetCharacters(datasetElement, mediaObjectsById);

		return {
			taxons: loadDatasetTaxons(datasetElement, mediaObjectsById, charsAndStatesById.charactersById).array(),
			characters: charsAndStatesById.charactersById.array(),
			states: charsAndStatesById.statesById.array(),
			mediaObjects: mediaObjectsById.array(),
		};
	}

	function loadMediaObjects(datasetElement:Xml):Map<String, MediaObject> {
		final mediaObjectsElement = datasetElement.firstElementNamed("MediaObjects");
		final mediaObjectsById:Map<String, MediaObject> = [];

		if (mediaObjectsElement == null)
			return mediaObjectsById;

		for (mediaObjectElement in mediaObjectsElement.elementsNamed("MediaObject")) {
			final sourceElement = mediaObjectElement.firstElementNamed("Source");

			if (sourceElement != null) {
				final id = assertNotNull(mediaObjectElement.get("id"), new SddException("A MediaObject declaration misses its 'id'."));
				final representation = loadRepresentation(mediaObjectElement.firstElementNamed("Representation"), mediaObjectsById);

				mediaObjectsById.set(id, {
					id: id,
					source: sourceElement.get("href"),
					label: representation.label,
					detail: representation.detail
				});
			}
		}

		return mediaObjectsById;
	}

	function loadRepresentation(representationElement:Xml, mediaObjectsByRef:Map<String, MediaObject>):Representation {
		if (representationElement == null)
			return {
				mediaObjectsRefs: [],
				label: "",
				detail: "",
			};
		final mediaObjectsRefs = [];

		for (mediaObjectElement in representationElement.elementsNamed("MediaObject")) {
			mediaObjectsRefs.push(new MediaObjectRef(assertNotNull(mediaObjectElement.get("ref"), new SddException("A MediaObject is missing its ref."))));
		}
		final labelNode = representationElement.firstElementNamed("Label");
		final detailElement = representationElement.firstElementNamed("Detail");

		return {
			label: if (labelNode != null) labelNode.innerText() else "_",
			detail: if (detailElement != null) detailElement.innerText() else "_",
			mediaObjectsRefs: mediaObjectsRefs
		};
	}

	function logException(exception:SddException) {
		exceptionLog.push(exception.message);
	}

	inline function assertNotNull<T>(value:Null<T>, exception:SddException):T {
		if (value == null)
			throw exception;
		return value;
	}

	function loadDatasetTaxons(datasetElement:Xml, mediaObjectsById:Map<String, MediaObject>, charactersById:Map<String, Character>):Map<String, Taxon> {
		final taxonsById:Map<String, Taxon> = [];
		final taxonNamesElement = datasetElement.firstElementNamed("TaxonNames");

		if (taxonNamesElement == null)
			return [];

		for (taxonElement in taxonNamesElement.elementsNamed("TaxonName")) {
			final taxonId = assertNotNull(taxonElement.get("id"), new SddException("A Taxon is missing its 'id'."));

			taxonsById.set(taxonId, new Taxon(taxonId, null, loadRepresentation(taxonElement.firstElementNamed("Representation"), mediaObjectsById)));
		}

		final codedDescriptionsElement = datasetElement.firstElementNamed("CodedDescriptions");

		if (codedDescriptionsElement != null) {
			for (codedDescriptionElement in codedDescriptionsElement.elementsNamed("CodedDescription"))
				try {
					final scopeElement = assertNotNull(codedDescriptionElement.firstElementNamed("Scope"),
						new SddException("A CodedDescription is missing its 'Scope'."));
					final taxonNameElement = assertNotNull(scopeElement.firstElementNamed("TaxonName"),
						new SddException("A CodedDescription Scope doesn't have a 'Taxon' element, which is the only one supported by this loader."));
					final taxonId = assertNotNull(taxonNameElement.get("ref"), new SddException("A TaxonName is missing its 'ref'."));
					final representation = loadRepresentation(codedDescriptionElement.firstElementNamed("Representation"), mediaObjectsById);
					final taxonToAugment = assertNotNull(taxonsById.get(taxonId), new SddRefException("Scope > TaxonName", "Taxon", taxonId));
					Representation.assign(taxonToAugment, representation);

					final summaryDataElement = codedDescriptionElement.firstElementNamed("SummaryData");

					if (summaryDataElement != null) {
						final categoricalElements = summaryDataElement.elementsNamed("Categorical");

						for (categoricalElement in categoricalElements) {
							final categorical:CategoricalRef = {
								ref: assertNotNull(categoricalElement.get("ref"), new SddException("A Categorical is missing its 'ref'.")),
								stateRefs: []
							};
							for (stateElement in categoricalElement.elementsNamed("State")) {
								final stateId = assertNotNull(stateElement.get("ref"), new SddException("A State is missing its 'ref'."));
								categorical.stateRefs.push(new StateRef(stateId));
							}
							taxonToAugment.categoricals.push(categorical);
						}
					}
				} catch (e:SddException) {
					if (strictMode) {
						throw e;
					} else {
						logException(e);
					}
				}
		}

		final taxonHierarchiesElement = datasetElement.firstElementNamed("TaxonHierarchies");
		final taxonHierarchyElement = if (taxonHierarchiesElement != null) {
			taxonHierarchiesElement.firstElementNamed("TaxonHierarchy");
		} else {
			null;
		}
		final nodesElement = if (taxonHierarchyElement != null) {
			taxonHierarchyElement.firstElementNamed("Nodes");
		} else {
			null;
		}

		if (nodesElement != null) {
			final hierarchiesById:Map<String, TaxonHierarchy> = [];

			for (nodeElement in nodesElement.elementsNamed("Node"))
				try {
					final hierarchyId = assertNotNull(nodeElement.get("id"), new SddException("A TaxonHierarchy > Nodes > Node is missing its 'id'."));
					final taxonNameElement = assertNotNull(nodeElement.firstElementNamed("TaxonName"),
						new SddException("A TaxonHierarchy > Nodes > Node is missing its 'TaxonName'."));
					final taxonId = assertNotNull(taxonNameElement.get("ref"),
						new SddException("A TaxonHierarchy > Nodes > Node > TaxonName is missing its 'ref'."));
					final taxon = assertNotNull(taxonsById.get(taxonId), new SddRefException("TaxonHierarchy > Nodes > Node > TaxonName", "Taxons", taxonId));
					var hierarchy = hierarchiesById.get(hierarchyId);

					taxon.hid = hierarchyId;

					if (hierarchy == null) {
						hierarchy = {taxon: taxon, childrenHierarchyIds: []};
					} else {
						hierarchy.taxon = taxon;
					}
					hierarchiesById.set(hierarchyId, hierarchy);

					final parentElement = nodeElement.firstElementNamed("Parent");

					if (parentElement != null) {
						final parentId = assertNotNull(parentElement.get("ref"), new SddException("A TaxonHierarchy >> Parent is missing its 'ref'."));
						var parent = hierarchiesById.get(parentId);
						if (parent == null) {
							parent = {taxon: null, childrenHierarchyIds: [hierarchyId]};
							hierarchiesById.set(parentId, parent);
						} else {
							parent.childrenHierarchyIds.push(hierarchyId);
						}
					}
				} catch (e:SddException) {
					if (strictMode) {
						throw e;
					} else {
						logException(e);
					}
				}
			for (hierarchy in hierarchiesById) {
				if (hierarchy.taxon == null)
					trace(hierarchy);
				final augmentedTaxon = hierarchy.taxon;

				for (hid in hierarchy.childrenHierarchyIds) {
					final child = hierarchiesById.get(hid).taxon;
					child.parentId = augmentedTaxon.id;
					augmentedTaxon.childrenIds.push(child.id);
				}
			}
		}

		return taxonsById;
	}

	function loadDatasetCharacters(datasetElement:Xml, mediaObjectsById:Map<String, MediaObject>):CharactersAndStatesById {
		final charactersById:Map<String, Character> = [];
		final charactersElements = datasetElement.firstElementNamed("Characters");
		final statesById:Map<String, State> = [];

		if (charactersElements == null)
			return {charactersById: charactersById, statesById: statesById};

		for (characterElement in charactersElements.elements())
			try {
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

				charactersById.set(characterId,
					new Character(characterId, null, loadRepresentation(characterElement.firstElementNamed("Representation"), mediaObjectsById), states));
			} catch (e:SddException) {
				if (strictMode) {
					throw e;
				} else {
					logException(e);
				}
			}
		final characterTreesElement = datasetElement.firstElementNamed("CharacterTrees");

		if (characterTreesElement != null) {
			for (characterTreeElement in characterTreesElement.elementsNamed("CharacterTree")) {
				final nodesElement = characterTreeElement.firstElementNamed("Nodes");

				if (nodesElement != null) {
					for (charNodeElement in nodesElement.elementsNamed("CharNode"))
						try {
							final characterElement = assertNotNull(charNodeElement.firstElementNamed("Character"),
								new SddException("A CharNode is missing its 'Character'."));
							final characterRef = assertNotNull(characterElement.get("ref"), new SddException("A CharNode > Character is missing its 'ref."));
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
										augmentedCharacter.inapplicableStatesRefs.push(new StateRef(state.id));
										augmentedCharacter.parentId = state.characterId;
									}
								}
							}
							if (augmentedCharacter.inapplicableStatesRefs.length > 0) {
								charactersById.get(augmentedCharacter.parentId).childrenIds.push(augmentedCharacter.id);
							}
						} catch (e:SddException) {
							if (strictMode) {
								throw e;
							} else {
								logException(e);
							}
						}
				}
			}
		}
		return {charactersById: charactersById, statesById: statesById};
	}

	public function load(text:String):Array<Dataset> {
		final xml = Xml.parse(text);
		final datasetsElements = xml.firstElement();
		final datasets = [];

		for (datasetElement in datasetsElements.elementsNamed("Dataset")) {
			datasets.push(loadDataset(datasetElement));
		}

		return datasets;
	}
}
