package bunga;

@:keep
@:expose
class TaxonToTex {
    public static function export(taxons:Array<Taxon>):String {
        final texTemplate = haxe.Resource.getString("tex_template");
		final template = new haxe.Template(texTemplate);

		return template.execute({taxons: taxons});
    }
}