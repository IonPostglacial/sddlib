package bunga;

@:structInit
class Field {
	public var std:Bool;
	public var id:String;
	public var label:String;

	public static final standard:Array<Field> = [
		{std: true, id: "name2", label: "Syn"},
		{std: true, id: "vernacularName", label: "NV"},
		{std: true, id: "vernacularName2", label: "NV2"},
		{std: true, id: "meaning", label: "Sense"},
		{std: true, id: "noHerbier", label: "N° Herbier"},
		{std: true, id: "herbariumPicture", label: "Herbarium Picture"},
		{std: true, id: "website", label: "Website"},
	];
}
