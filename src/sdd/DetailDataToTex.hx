package sdd;

@:keep
@:expose
class DetailDataToTex {
    public static function export(representations:Array<DetailData>):String {
        final texTemplate = haxe.Resource.getString("tex_template");
		final template = new haxe.Template(texTemplate);

		return template.execute({representations: representations});
    }
}