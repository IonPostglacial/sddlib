package sdd;

class Saver {
	public var datasets:Array<Dataset>;
	public var mediaObjectsCount = 0;

	public function new(datasets:Array<Dataset>) {
		this.datasets = datasets;
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

	@:keep function taxonParentHid(resolve:(code:String) -> Dynamic, parentId:String):String {
		return "";
	}

	public function save():String {
		final sddTemplate = haxe.Resource.getString("sdd_template");
		final template = new haxe.Template(sddTemplate);

		return template.execute({datasets: datasets}, this);
	}
}
