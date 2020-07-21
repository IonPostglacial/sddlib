package sdd;

using Lambda;

@:keep
@:expose
class Saver {
	public var datasets:Array<Dataset>;
	public var mediaObjectsCount = 0;

	public function new(datasets:Array<Dataset>) {
		this.datasets = datasets;
	}

	@:keep function taxonParentHid(resolve:(code:String) -> Dynamic, parentId:String):String {
		final parent = this.datasets[0].taxons.find(t -> t.id == parentId);
		return parent.hid;
	}

	@:keep function html(resolve:(code:String) -> Dynamic, htmlText:String):String {
		return StringTools.htmlEscape(htmlText);
	}

	public function save():String {
		final sddTemplate = haxe.Resource.getString("sdd_template");
		final template = new haxe.Template(sddTemplate);

		return template.execute({datasets: datasets}, this);
	}
}
