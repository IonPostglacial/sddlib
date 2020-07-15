package sdd;

class Saver {
	public var datasets:Array<Dataset>;
	public var mediaObjectsCount = 0;

	public function new(datasets:Array<Dataset>) {
		this.datasets = datasets;
	}

	@:keep function taxonParentHid(resolve:(code:String) -> Dynamic, parentId:String):String {
		return "";
	}

	public function save():String {
		final sddTemplate = haxe.Resource.getString("sdd_template");
		final template = new haxe.Template(sddTemplate);

		return template.execute({datasets: datasets}, this);
	}
}
