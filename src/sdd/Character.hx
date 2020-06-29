package sdd;

class Character extends Representation {
    public var id: String;
    public var statesIds: Array<String>;
    public var inapplicableStatesIds: Array<String> = [];
    public var parentId: Null<String>;
    public var children: Array<Character> = [];

    public function new(id: String, representation: Representation, statesIds: Array<String>) {
        Representation.assign(this, representation);
        this.id = id;
        this.statesIds = statesIds;
    }
}