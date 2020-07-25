package bunga;

class Character extends HierarchicalItem {
    public inline function new(id, hid, parentId, topLevel, children, data: DetailData) {
        super("character", id, hid, parentId, topLevel, children, data);
    }
}