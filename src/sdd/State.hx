package sdd;

class State extends Representation {
    public var id: String;

    public function new(id: String, representation: Representation) {
        this.id = id;
        Representation.assign(this, representation);
    }

    public function copy(): State {
        return new State(this.id, { label: this.label, detail: this.detail, mediaObjects: this.mediaObjects });
    }
}