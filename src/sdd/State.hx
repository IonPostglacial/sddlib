package sdd;

class State extends Representation {
    public var id: String;
    public var characterId: String;

    public function new(id: String, characterId: String, representation: Representation) {
        this.id = id;
        this.characterId = characterId;
        Representation.assign(this, representation);
    }
}