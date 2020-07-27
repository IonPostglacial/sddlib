package bunga;

import haxe.DynamicAccess;

@:keep
@:expose
@:structInit
class Taxon extends HierarchicalItem {
    public var descriptions:Array<Description>;

    public inline function new(id, hid, parentId, topLevel, children, descriptions, data: DetailData) {
        super("taxon", id, hid, parentId, topLevel, children, data);
        this.descriptions = descriptions;
    }

    public static function fromSdd(taxon: sdd.Taxon, extraFields:Array<Field>, photosByRef:DynamicAccess<String>, descriptors:DynamicAccess<Character>, statesById:DynamicAccess<State>): Taxon {
        final descriptions = new Map<String, Description>();
        for (categorical in taxon.categoricals) {
            final description:Description = {
                descriptor: descriptors[categorical.ref],
                states: categorical.stateRefs.map(s -> statesById[s.ref])
            };
            descriptions[categorical.ref] = description;
        }
        return {
            id: taxon.id,
            hid: taxon.id,
            parentId: taxon.parentId,
            topLevel: taxon.parentId == null,
            children: taxon.childrenIds,
            descriptions: [for (_ => value in descriptions) value],
            data: DetailData.fromRepresentation(taxon, extraFields, photosByRef)
        };
    }
}