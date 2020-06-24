package sdd;

class Taxon extends Representation {
    public var id: String;
    public var parentId: Null<String>;
    public var statesByCharacterId: Map<String, Array<State>> = [];
    public var children: Array<Taxon> = [];

    public function new(id: String, representation: Representation) {
        this.id = id;
        Representation.assign(this, representation);
    }
}