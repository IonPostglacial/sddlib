package sdd;

class Taxon extends Representation {
    public var id: String;
    public var parentId: Null<String>;
    public var selectedStatesIds: Array<String> = [];
    public var childrenIds: Array<String> = [];

    public function new(id: String, representation: Representation) {
        this.id = id;
        Representation.assign(this, representation);
    }
}