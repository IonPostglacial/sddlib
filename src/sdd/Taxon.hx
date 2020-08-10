package sdd;

@:structInit
class Taxon extends Representation {
	public var id:String;
	public var hid:String;
	public var parentId:Null<String>;
	public var categoricals:Array<CategoricalRef> = [];
	public var childrenIds:Array<String> = [];

	public function new(id:String, parentId:Null<String>, representation:Representation, ?childrenIds, ?categoricals) {
		super(representation.label, representation.detail, representation.mediaObjectsRefs);
		this.id = id;
		if (childrenIds != null)
			this.childrenIds = childrenIds;
		if (categoricals != null)
			this.categoricals = categoricals;
	}
}
