package bunga;

import sdd.MediaObject;
import haxe.DynamicAccess;

@:structInit class SddTaxonData {
	public var taxon:sdd.Taxon;
	public var mediaObjects:Array<sdd.MediaObject>;
}

@:keep
@:expose
@:structInit
class Taxon extends HierarchicalItem {
	public var descriptions:Array<Description>;
	public var bookInfoByIds:DynamicAccess<BookInfo> = {};

	public inline function new(item:HierarchicalItem, descriptions, ?bookInfoByIds) {
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

	public static function toSdd(taxon:Taxon, extraFields:Array<Field>, mediaObjects:Array<MediaObject>):SddTaxonData {
		final sddTaxon:sdd.Taxon = {
			id: taxon.id,
			parentId: taxon.parentId,
			representation: taxon.toRepresentation(extraFields),
			childrenIds: taxon.children.keys(),
			categoricals: taxon.descriptions.map(function(d):sdd.CategoricalRef return {
				ref: d.descriptor.id,
				stateRefs: d.states.map(s -> new sdd.StateRef(s.id))
			}),
		};
		return {
			taxon: sddTaxon,
			mediaObjects: []
		};
	}
}
