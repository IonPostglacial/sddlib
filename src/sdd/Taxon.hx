package sdd;

class Taxon extends Representation {
    public var id: String;
    public var statesByCharacterId: Map<String, Array<State>> = [];

    public function new(id: String, representation: Representation) {
        this.id = id;
        Representation.assign(this, representation);
    }
}