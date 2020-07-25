package bunga;

class HierarchicalItem extends DetailData {
    public var type: String;
    public var id:String;
    public var hid:String;
    public var parentId:String;
    public var topLevel:Bool;
    public var children:Array<String>;

    public inline function new(type, id, hid, parentId, topLevel, children, data: DetailData) {
        super(data.name, data.author, data.nameCN,
			data.fasc, data.page, data.detail, data.photos, data.fields, 
			data.name2, data.vernacularName, data.vernacularName2, data.meaning, data.noHerbier, data.website, data.herbariumPicture, data.extra);
        this.type = type;
        this.id = id;
        this.hid = hid;
        this.parentId = parentId;
        this.topLevel = topLevel;
        this.children = children;
    }
}