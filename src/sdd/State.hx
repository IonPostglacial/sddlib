package sdd;

@:structInit
class State extends Representation {
	public var id:String;
	public var characterId:String;

	public function new(id:String, characterId:String, representation:Representation) {
		super(representation.label, representation.detail, representation.mediaObjectsRefs);
		this.id = id;
		this.characterId = characterId;
	}
}
