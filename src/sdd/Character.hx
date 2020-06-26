package sdd;

class Character extends Representation {
    public var id: String;
    public var states: Array<State>;
    public var inapplicableStates: Array<State> = [];
    public var parentId: Null<String>;
    public var children: Array<Character> = [];

    public function new(id: String, representation: Representation, states: Array<State>) {
        Representation.assign(this, representation);
        this.id = id;
        this.states = states;
    }
}