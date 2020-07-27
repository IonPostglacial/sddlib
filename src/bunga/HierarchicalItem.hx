package bunga;

import haxe.DynamicAccess;

@:structInit
class HierarchicalItem<T> extends DetailData {
    public var type: String;
    public var id:String;
    public var hid:String;
    public var parentId:Null<String>;
    public var topLevel:Bool;
    public var children:DynamicAccess<T>;

    public function setEmptyChildren(childrenIds:Array<String>){
        for (id in childrenIds) {
            children[id] = null;
        }
    }

    public function hydrateChildren(hierarchyById:DynamicAccess<T>) {
        for (id in children.keys()) {
            children[id] = hierarchyById[id];
        }
    }

    public inline function new(type, id, hid, parentId, topLevel, childrenIds:Array<String>, data: DetailData) {
        super(data.name, data.author, data.nameCN,
			data.fasc, data.page, data.detail, data.photos, data.fields, 
			data.name2, data.vernacularName, data.vernacularName2, data.meaning, data.noHerbier, data.website, data.herbariumPicture, data.extra);
        this.type = type;
        this.id = id;
        this.hid = hid;
        this.parentId = parentId;
        this.topLevel = topLevel;
        this.children = {};
        for (id in childrenIds) {
            children[id] = null;
        }
    }
}