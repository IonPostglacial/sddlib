package sdd;

class State extends Representation {
    public var id: String;
    public var characterId: String;

    public function new(id: String, characterId: String, representation: Representation) {
        this.id = id;
        this.characterId = characterId;
        Representation.assign(this, representation);
    }

    public function copy(): State {
        return new State(this.id, this.characterId, { label: this.label, detail: this.detail, mediaObjects: this.mediaObjects });
    }
}