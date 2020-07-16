import sdd.MediaObjectRef;
import sdd.Representation;
import utest.Assert;
import utest.Test;

class TestLoader extends Test {
	var loader:sdd.Loader;
	var sddSample:String;
	var datasets:Array<sdd.Dataset>;

	function setupClass() {
		loader = new sdd.Loader(false);
		sddSample = haxe.Resource.getString("sdd_sample");
		datasets = loader.load(sddSample);
	}

	inline function assertSameRepresentation(expected:Representation, actual:Representation) {
		Assert.equals(expected.label, actual.label);
		Assert.equals(expected.detail, actual.detail);
		Assert.same(expected.mediaObjectsRefs, actual.mediaObjectsRefs);
	}

	function testNoErrors() {
		Assert.equals(0, loader.exceptionLog.length);
	}

	function testTaxons() {
		Assert.equals(3, datasets[0].taxons.length);

		Assert.equals("myt-1", datasets[0].taxons[0].id);
		assertSameRepresentation({
			label: "Testing some things",
			detail: "Syn: Mikmak<br><br>NV: Moumouk<br><br>NV2: Tipi<br><br>Sense: Moumoute argentée<br><br>N° Herbier: 6<br><br>Herbarium Picture: 2<br><br>Flore Madagascar et Comores<br>fasc 4<br>page 5<br><br>Website: https://nicolas.galipot.net<br><br><p>Doubidou</p><p>wah</p>",
			mediaObjectsRefs: [new MediaObjectRef("m1")],
		}, datasets[0].taxons[0]);
		Assert.equals("myt-2", datasets[0].taxons[1].id);
		assertSameRepresentation({label: "Tip Top", detail: "Some detail > 0 in here."}, datasets[0].taxons[1]);
		Assert.equals("myt-3", datasets[0].taxons[2].id);
		assertSameRepresentation({label: "Blabla", detail: "_"}, datasets[0].taxons[2]);
	}

	function testDataset() {
		Assert.equals(1, datasets.length);
	}

	function testCharacters() {
		Assert.equals(5, datasets[0].characters.length);
	}
}
