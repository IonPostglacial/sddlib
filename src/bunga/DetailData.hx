package bunga;

import haxe.DynamicAccess;
using StringTools;

@:keep
@:expose
@:structInit
class DetailData {
	public var name:String;
	public var author:String;
	public var nameCN:String;
	public var name2:String;
	public var vernacularName:String;
	public var vernacularName2:String;
	public var meaning:String;
	public var herbariumPicture:String;
	public var website:String;
	public var noHerbier:Null<Int>;
	public var fasc:Null<Int>;
	public var page:Null<Int>;
	public var detail:String;
	public var photos:Array<String>;
	public var fields:Array<Field>;
	public var extra:Dynamic;

	inline function new(name:Null<String>, author:Null<String>, nameCN:Null<String>,
			fasc, page, detail, photos, fields, 
			?name2, ?vernacularName, ?vernacularName2, ?meaning, ?noHerbier, ?website, ?herbariumPicture, ?extra) {
		this.name = if (name != null) name.trim() else "";
		this.author = if (author != null) author.trim() else "";
		this.nameCN = if (nameCN != null) nameCN.trim() else "";
		this.name2 = name2;
		this.vernacularName = vernacularName;
		this.vernacularName2 = vernacularName2;
		this.meaning = meaning;
		this.herbariumPicture = herbariumPicture;
		this.website = website;
		this.fasc = fasc;
		this.page = page;
		this.detail = detail;
		this.fields = fields;
		this.photos = photos;
		this.extra = {};
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

	public function toRepresentation():sdd.Representation {
		return {
			label: name + if (author != null) ' / $author' else "" + if (nameCN != null) ' / $nameCN' else "",
			detail: "" + fields.map(function(field) {
				final value = Reflect.field(if (field.std) this else this.extra, field.id);
				if (value == null || value == "")
					return "";
				return '${field.label}: $value<br><br>';
			}).join("") + if (fasc != null) 'Flore Madagascar et Comores<br>fasc ${fasc}<br>page ${page}<br><br>' else "" + detail,
		};
	}

	public inline static function fromRepresentation(representation:sdd.Representation, extraFields:Array<Field>, photosByRef:DynamicAccess<String>):DetailData {
		final names = representation.label.split("/");
		final name = names[0], author = names[1], nameCN = names[2];

		final fields = Field.standard.concat(extraFields);
		final floreRe = ~/Flore Madagascar et Comores\s*<br>\s*fasc\s+(\d*)\s*<br>\s*page\s+(null|\d*)/i;
		var fasc:Null<Int> = null, page:Null<Int> = null;

		if (floreRe.match(representation.detail)) {
			fasc = Std.parseInt(floreRe.matched(1));
			page = Std.parseInt(floreRe.matched(2));
		}
		var detail = floreRe.replace(removeFromDescription(representation.detail, fields.map(field -> field.label)), "");

		final emptyParagraphRe = ~/<p>(\n|\t|\s|<br>|&nbsp;)*<\/p>/gi;
		if (emptyParagraphRe.match(detail)) {
			detail = emptyParagraphRe.replace(detail, "");
		}
		final photos = representation.mediaObjectsRefs.map(m -> photosByRef[m.ref]);
		final data:DetailData = { name: name, author: author, nameCN: nameCN, fasc: fasc, page: page, detail: detail, photos: photos, fields: extraFields };

		for (field in fields) {
			Reflect.setField(if (field.std) data else data.extra, field.id, findInDescription(representation.detail, field.label));
		}
		return data;
	}
}
