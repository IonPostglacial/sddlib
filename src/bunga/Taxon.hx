package bunga;

import haxe.DynamicAccess;

@:structInit
class Taxon extends HierarchicalItem<Taxon> {
	public var descriptions:Array<Description>;
	public var bookInfoByIds:DynamicAccess<BookInfo> = {};

	public inline function new(item:HierarchicalItem<Taxon>, descriptions, ?bookInfoByIds) {
		super("taxon", item.id, item.hid, item.parentId, item.topLevel, item.children.keys(), item);
		this.descriptions = descriptions;
		if (bookInfoByIds != null) {
			this.bookInfoByIds = bookInfoByIds;
		}
	}

	public static function fromSdd(taxon:sdd.Taxon, extraFields:Array<Field>, photosByRef:DynamicAccess<String>, descriptors:DynamicAccess<Character>,
			statesById:DynamicAccess<State>):Taxon {
		final descriptions = new Map<String, Description>();
		for (categorical in taxon.categoricals) {
			final description:Description = {
				descriptor: descriptors[categorical.ref],
				states: categorical.stateRefs.map(s -> statesById[s.ref])
			};
			descriptions[categorical.ref] = description;
		}
		return {
			item: {
				type: "taxon",
				id: taxon.id,
				hid: taxon.id,
				parentId: taxon.parentId,
				topLevel: taxon.parentId == null,
				childrenIds: taxon.childrenIds,
				data: DetailData.fromRepresentation(taxon, extraFields, photosByRef)
			},
			descriptions: [for (_ => value in descriptions) value],
		};
	}
}
