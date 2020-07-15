package;

class Main {
	public static function main() {
		final loader = new sdd.Loader(false);
		final sdd_sample = haxe.Resource.getString("sdd_missref");
		final datasets = loader.load(sdd_sample);
		trace(loader.exceptionLog);

		final saver = new sdd.Saver(datasets);
		final sdd = saver.save();

		trace(sdd);
	}
}
