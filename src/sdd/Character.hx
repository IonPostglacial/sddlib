package sdd;

@:structInit
class Character extends Representation {
	public var id:String;
	public var states:Array<State> = [];
	public var inapplicableStatesRefs:Array<StateRef> = [];
	public var parentId:Null<String>;
	public var childrenIds:Array<String> = [];

	public function new(id:String, parentId:String, representation:Representation, ?states, ?inapplicableStatesRefs, ?childrenIds) {
		super(representation.label, representation.detail, representation.mediaObjectsRefs);
		this.id = id;
		if (states != null)
			this.states = states;
		if (inapplicableStatesRefs != null)
			this.inapplicableStatesRefs = inapplicableStatesRefs;
		if (childrenIds != null)
			this.childrenIds = childrenIds;
	}
}
