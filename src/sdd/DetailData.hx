package sdd;

using StringTools;

class DetailData {
	public var name:String;
	public var name2:String;
	public var nameCN:String;
	public var vernacularName:String;
	public var vernacularName2:String;
	public var author:String;
	public var meaning:String;
	public var herbariumPicture:String;
	public var website:String;
	public var noHerbier:Null<Int>;
	public var fasc:Null<Int>;
	public var page:Null<Int>;
	public var detail:String;
	public var extra:Dynamic;

	function new(name, nameCN, fasc, page, detail) {
		this.name = name;
		this.nameCN = nameCN;
		this.fasc = fasc;
		this.page = page;
		this.detail = detail;
	}

	static function escapeRegExp(string:String) {
		return ~/[.*+?^${}()|[\]\\]/g.replace(string, '\\$&'); // $& means the whole matched string
	}

	static function findInDescription(description:String, section:String) {
		final re = new EReg('${escapeRegExp(section)}\\s*:\\s*(.*?)(?=<br><br>)', "i");
		if (re.match(description))
			return re.matched(1).trim();
		else
			return "";
	}

	static function removeFromDescription(description:String, sections:Array<String>) {
		var desc = description;

		for (section in sections) {
			final re = new EReg('${escapeRegExp(section)}\\s*:\\s*(.*?)(?=<br><br>)', "i");
			desc = re.replace(desc, "");
		}
		return desc;
	}

	public static function fromRepresentation(representation:Representation, extraFields:Array<Field>):DetailData {
		final names = representation.label.split(" // ");
		final name = names[0], nameCN = names[1];

		final fields = Field.standard.concat(extraFields);
		final floreRe = ~/Flore Madagascar et Comores\s*<br>\s*fasc\s*(\d*)\s*<br>\s*page\s*(\d*)/i;
		var fasc:Null<Int> = null, page:Null<Int> = null;

		if (floreRe.match(representation.detail)) {
			fasc = Std.parseInt(floreRe.matched(1));
			page = Std.parseInt(floreRe.matched(2));
		}
		var detail = floreRe.replace(removeFromDescription(representation.detail, fields.map(field -> field.label)), "");
		final data = new DetailData(name, nameCN, fasc, page, detail);

		for (field in fields) {
			// TODO: implement extra fields
			Reflect.setField(data, field.id, findInDescription(representation.detail, field.label));
		}
		return data;
	}
}
