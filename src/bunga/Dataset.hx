package bunga;

import haxe.DynamicAccess;

@:keep
@:expose
@:structInit
class Dataset extends DetailData {
	public var items:DynamicAccess<Taxon>;
	public var descriptors:DynamicAccess<Character>;
	public var books:Array<Book>;

	public function new(items, descriptors, ?books) {
		super();
		this.items = items;
		this.descriptors = descriptors;
		this.books = if(books != null) books else [for (book in Book.standard) book];
	}

	static function extractStatesById(sddContent:sdd.Dataset, photosByRef:DynamicAccess<String>) {
		final statesById:DynamicAccess<State> = {};

		for (state in sddContent.states) {
			statesById[state.id] = State.fromSdd(state, photosByRef);
		}
		return statesById;
	}

	static function extractItemsById(sddContent:sdd.Dataset, descriptors, extraFields, statesById, photosByRef) {
		final itemsById:DynamicAccess<Taxon> = {};

		for (taxon in sddContent.taxons) {
			itemsById[taxon.id] = Taxon.fromSdd(taxon, extraFields, photosByRef, descriptors, statesById);
		}
		return itemsById;
	}

	static function extractDescriptorsById(sddContent:sdd.Dataset, statesById:DynamicAccess<State>, photosByRef:DynamicAccess<String>) {
		final descriptorsById:DynamicAccess<Character> = {};

		for (character in sddContent.characters) {
			descriptorsById[character.id] = Character.fromSdd(character, photosByRef, statesById);
		}
		return descriptorsById;
	}

	static function extractPhotosByRef(sddContent:sdd.Dataset) {
		final photosByRef:DynamicAccess<String> = {};

		for (mediaObject in sddContent.mediaObjects) {
			photosByRef[mediaObject.id] = mediaObject.source;
		}
		return photosByRef;
	}

	public static function fromSdd(dataset:sdd.Dataset, extraFields:Array<Field>):Dataset {
		final photosByRef = extractPhotosByRef(dataset);
		final statesById = extractStatesById(dataset, photosByRef);

		final descriptors = extractDescriptorsById(dataset, statesById, photosByRef);

		for (descriptor in descriptors) {
			descriptor.hydrateChildren(descriptors);
		}

		final items = extractItemsById(dataset, descriptors, extraFields, statesById, photosByRef);

		for (item in items) {
			item.hydrateChildren(items);
		}

		return {items: items, descriptors: descriptors};
	}
}
