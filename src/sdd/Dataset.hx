package sdd;

@:structInit
class Dataset {
    public var taxonsById: Map<String, Taxon>;
    public var charactersById: Map<String, Character>;
}