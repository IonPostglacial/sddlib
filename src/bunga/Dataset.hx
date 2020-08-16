package bunga;

import haxe.DynamicAccess;

@:keep
@:expose
@:structInit
class Dataset {
	public var id:String = "0";
	public var taxons:DynamicAccess<Taxon>;
	public var descriptors:DynamicAccess<Character>;
	public var books:Array<Book>;
	public var extraFields:Array<Field>;
	public var dictionaryEntries:DynamicAccess<Any>;

	public function new(id, taxons, descriptors, ?books, ?extraFields, ?dictionaryEntries) {
		this.taxons = taxons;
		this.descriptors = descriptors;
		this.books = if (books != null) books else [for (book in Book.standard) book];
		this.extraFields = if (extraFields != null) extraFields else [];
		this.dictionaryEntries = if (dictionaryEntries != null) dictionaryEntries else {};
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
			descriptor.hydrateChildren(cast descriptors);
		}

		final taxons = extractItemsById(dataset, descriptors, extraFields, statesById, photosByRef);

		for (item in taxons) {
			item.hydrateChildren(cast taxons);
		}

		return {id: "0", taxons: taxons, descriptors: descriptors};
	}

	public static function toSdd(dataset:Dataset, extraFields:Array<Field>):sdd.Dataset {
		var taxons = new Array<sdd.Taxon>(),
			characters = new Array<sdd.Character>();
		var states = new Array<sdd.State>(),
			mediaObjects = new Array<sdd.MediaObject>();

		for (taxon in dataset.taxons) {
			final sddData = Taxon.toSdd(taxon, extraFields, mediaObjects);
			taxons.push(sddData.taxon);
			mediaObjects = mediaObjects.concat(sddData.mediaObjects);
		}
		for (character in dataset.descriptors) {
			final sddData = Character.toSdd(character, extraFields, mediaObjects);
			characters.push(sddData.character);
			states = states.concat(sddData.states);
			mediaObjects = mediaObjects.concat(sddData.mediaObjects);
		}
		return {
			taxons: taxons,
			characters: characters,
			states: states,
			mediaObjects: mediaObjects,
		};
	}
}
