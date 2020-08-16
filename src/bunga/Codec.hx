package bunga;

import haxe.DynamicAccess;

class CodedHierarchicalItem extends Item {
	public var type:String;
	public var hid:String;
	public var parentId:Null<String>;
	public var topLevel:Bool;
	public var children:Array<String> = [];

	public function new(item:HierarchicalItem) {
		super(item.id,
			new DetailData(item.name, item.author, item.nameCN, item.fasc, item.page, item.detail, item.photos, item.name2, item.vernacularName,
				item.vernacularName2, item.meaning, item.noHerbier, item.website, item.herbariumPicture, item.extra));
		this.type = item.type;
		this.hid = item.hid;
		this.parentId = item.parentId;
		this.topLevel = item.topLevel;
		for (child in item.children) {
			if (child == null) {
				trace(item.name + " has null child");
				trace(item);
			} else {
				this.children.push(child.id);
			}
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

class CodedTaxon extends CodedHierarchicalItem {
	public var descriptions:Array<CodedDescription>;
	public var bookInfoByIds:DynamicAccess<BookInfo> = {};

	public function new(taxon:Taxon) {
		super(taxon);
		bookInfoByIds = taxon.bookInfoByIds;
		descriptions = taxon.descriptions.map(d -> new CodedDescription(d.descriptor.id, d.states.map(s -> s.id)));
	}
}

class CodedCharacter extends CodedHierarchicalItem {
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
	public var id:String;
	public var states:Array<State>;
	public var taxons:Array<CodedTaxon>;
	public var descriptors:Array<CodedCharacter>;
	public var books:Array<Book>;
	public var extraFields:Array<Field>;
	public var dictionaryEntries:DynamicAccess<Any>;

	public static function getAllStates(dataset:Dataset):Array<State> {
		var states = [];
		for (character in dataset.descriptors) {
			states = states.concat(character.states);
		}
		return states;
	}

	public function new(dataset:Dataset) {
		id = dataset.id;
		taxons = [for (taxon in dataset.taxons) new CodedTaxon(taxon)];
		descriptors = [for (character in dataset.descriptors) new CodedCharacter(character)];
		states = getAllStates(dataset);
		books = dataset.books;
		extraFields = dataset.extraFields;
		dictionaryEntries = dataset.dictionaryEntries;
	}
}

@:keep
@:expose
class Codec {
	public static function decodeHierarchicalItem<T:Item>(item:CodedHierarchicalItem):HierarchicalItem {
		var item:HierarchicalItem = {
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

	public static function decodeTaxon(taxon:CodedTaxon, descriptions:DynamicAccess<Character>, states:DynamicAccess<State>, books:Array<Book>):Taxon {
		var bookInfoByIds = if (taxon.bookInfoByIds != null) taxon.bookInfoByIds else {};

		if (bookInfoByIds.keys().length == 0) {
			for (book in Book.standard) {
				final info:BookInfo = {
					fasc: if (book.id == "fmc") "" + taxon.fasc else "",
					page: if (book.id == "fmc") taxon.page else null,
					detail: ""
				};
				bookInfoByIds[book.id] = info;
			}
		}
		return {
			item: decodeHierarchicalItem(taxon),
			bookInfoByIds: bookInfoByIds,
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
		final taxons:DynamicAccess<Taxon> = {};
		final books = [for (book in Book.standard) book];

		for (state in dataset.states)
			states[state.id] = state;
		for (descriptor in dataset.descriptors)
			descriptors[descriptor.id] = decodeCharacter(descriptor, states);
		for (taxon in dataset.taxons)
			taxons[taxon.id] = decodeTaxon(taxon, descriptors, states, books);
		for (descriptor in descriptors)
			descriptor.hydrateChildren(cast descriptors);
		for (taxon in taxons)
			taxon.hydrateChildren(cast taxons);
		return {
			id: dataset.id,
			taxons: taxons,
			descriptors: descriptors,
			books: books,
			extraFields: dataset.extraFields,
			dictionaryEntries: dataset.dictionaryEntries,
		};
	}
}
