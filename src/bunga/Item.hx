package bunga;

import bunga.DetailData;

@:keep
@:expose
class Item extends DetailData {
	public var id:String;

	public inline function new(id:String, data:DetailData) {
		super(data.name, data.author, data.nameCN, data.fasc, data.page, data.detail, data.photos, data.name2, data.vernacularName, data.vernacularName2,
			data.meaning, data.noHerbier, data.website, data.herbariumPicture, data.extra);
		this.id = id;
	}
}
