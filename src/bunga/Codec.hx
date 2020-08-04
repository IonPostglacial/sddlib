package bunga;

import haxe.DynamicAccess;

class CodedHierarchicalItem<T:Item> extends Item {
	public var type:String;
	public var hid:String;
	public var parentId:Null<String>;
	public var topLevel:Bool;
	public var children:Array<String> = [];

	public function new(item:HierarchicalItem<T>) {
		super(item.id, new DetailData(item.name, item.author, item.nameCN, item.fasc, item.page, item.detail, item.photos, item.name2, item.vernacularName,
			item.vernacularName2, item.meaning, item.noHerbier, item.website, item.herbariumPicture, item.extra));
		this.type = item.type;
		this.hid = item.hid;
		this.parentId = item.parentId;
		this.topLevel = item.topLevel;
		for (child in item.children) {
			this.children.push(child.id);
		}
	}
}

class CodedDescription {
	public var descriptorId:String;
	public var statesIds:Array<String>;

	public function new(descriptorId, statesIds) {
		this.descriptorId = descriptorId;
		this.statesIds = statesIds;
	}
}

class CodedTaxon extends CodedHierarchicalItem<Taxon> {
	public var descriptions:Array<CodedDescription>;

	public function new(taxon:Taxon) {
		super(taxon);
		descriptions = taxon.descriptions.map(d -> new CodedDescription(d.descriptor.id, d.states.map(s -> s.id)));
	}
}

class CodedCharacter extends CodedHierarchicalItem<Character> {
	public var states:Array<String>;
	public var inapplicableStatesIds:Array<String>;
	public var inapplicableStates:Null<Array<State>>; // Only here to fix an oversight in the JS version

	public function new(character:Character) {
		super(character);
		states = character.states.map(s -> s.id);
		inapplicableStatesIds = character.inapplicableStates.map(s -> s.id);
	}
}

@:structInit
class CodedDataset {
	public var states:Array<State>;
	public var taxons:Array<CodedTaxon>;
	public var descriptors:Array<CodedCharacter>;

	public static function getAllStates(dataset:Dataset):Array<State> {
		var states = [];
		for (character in dataset.descriptors) {
			states = states.concat(character.states);
		}
		return states;
	}

	public function new(dataset:Dataset) {
		taxons = [for (taxon in dataset.items) new CodedTaxon(taxon)];
		descriptors = [for (character in dataset.descriptors) new CodedCharacter(character)];
		states = getAllStates(dataset);
	}
}

@:keep
@:expose
class Codec {
	public static function decodeHierarchicalItem<T:Item>(item:CodedHierarchicalItem<T>):HierarchicalItem<T> {
		var item:HierarchicalItem<T> = {
			type: item.type,
			id: item.id,
			hid: item.hid,
			parentId: item.parentId,
			topLevel: item.topLevel,
			childrenIds: item.children,
			data: item,
		};
		return item;
	}

	public static function decodeTaxon(taxon:CodedTaxon, descriptions:DynamicAccess<Character>, states:DynamicAccess<State>):Taxon {
		return {
			item: decodeHierarchicalItem(taxon),
			descriptions: taxon.descriptions.map(function(d):Description return {
				descriptor: descriptions[d.descriptorId],
				states: d.statesIds.map(id -> states[id]),
			}),
		};
	}

	public static function decodeCharacter(character:CodedCharacter, states:DynamicAccess<State>):Character {
		return {
			item: decodeHierarchicalItem(character),
			states: character.states.map(id -> states[id]),
			inapplicableStates: if (character.inapplicableStates != null) {
				character.inapplicableStates.map(s -> states[s.id]);
			} else {
				character.inapplicableStatesIds.map(id -> states[id]);
			},
		};
	}

	public static function encodeDataset(dataset:Dataset)
		return new CodedDataset(dataset);

	public static function decodeDataset(dataset:CodedDataset):Dataset {
		final states:DynamicAccess<State> = {};
		final descriptors:DynamicAccess<Character> = {};
		final items:DynamicAccess<Taxon> = {};

		for (state in dataset.states)
			states[state.id] = state;
		for (descriptor in dataset.descriptors)
			descriptors[descriptor.id] = decodeCharacter(descriptor, states);
		for (taxon in dataset.taxons)
			items[taxon.id] = decodeTaxon(taxon, descriptors, states);
		for (descriptor in descriptors)
			descriptor.hydrateChildren(descriptors);
		for (item in items)
			item.hydrateChildren(items);
		return {items: items, descriptors: descriptors};
	}
}
