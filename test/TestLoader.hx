import sdd.StateRef;
import sdd.State;
import sdd.Character;
import sdd.MediaObjectRef;
import sdd.Representation;
import sdd.Taxon;
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

	inline function assertSameTaxon(expected:Taxon, actual:Taxon) {
		assertSameRepresentation(expected, actual);
		Assert.equals(expected.id, actual.id);
		Assert.same(expected.childrenIds, actual.childrenIds);
		Assert.same(expected.categoricals, actual.categoricals);
	}

	inline function assertSameCharacter(expected:Character, actual:Character) {
		assertSameRepresentation(expected, actual);
		Assert.equals(expected.id, actual.id);
		Assert.equals(expected.parentId, actual.parentId);
		Assert.same(expected.states, actual.states);
		Assert.same(expected.childrenIds, actual.childrenIds);
		Assert.same(expected.inapplicableStatesRefs, actual.inapplicableStatesRefs);
	}

	function testNoErrors() {
		Assert.equals(0, loader.exceptionLog.length);
	}

	function testTaxons() {
		Assert.equals(3, datasets[0].taxons.length);

		assertSameTaxon(new Taxon("myt-1", null, {
			label: "Testing some things",
			detail: "Syn: Mikmak<br><br>NV: Moumouk<br><br>NV2: Tipi<br><br>Sense: Moumoute argentée<br><br>N° Herbier: 6<br><br>Herbarium Picture: 2<br><br>Flore Madagascar et Comores<br>fasc 4<br>page 5<br><br>Website: https://nicolas.galipot.net<br><br><p>Doubidou</p><p>wah</p>",
			mediaObjectsRefs: [new MediaObjectRef("m1")],
		}, ["myt-2"],
			[{ref: "myd-0", stateRefs: [new StateRef("s1631592861646693")]}]), datasets[0].taxons[0]);
		assertSameTaxon(new Taxon("myt-2", null, {label: "Tip Top", detail: "Some detail > 0 in here."}), datasets[0].taxons[1]);
		assertSameTaxon(new Taxon("myt-3", null, {label: "Blabla", detail: "_"}), datasets[0].taxons[2]);
	}

	function testDataset() {
		Assert.equals(1, datasets.length);
	}

	function testCharacters() {
		Assert.equals(5, datasets[0].characters.length);

		assertSameCharacter(new Character("myd-0", null, {label: "Some descriptor", detail: "_"}, [
			new State("s1631592861646693", "myd-0", {label: "state 1", detail: "_"}),
			new State("s311592861650493", "myd-0", {label: "and two", detail: "_"}),
			new State("s9021592861652163", "myd-0", {label: "and 3", detail: "_"}),
			new State("s4321592861653402", "myd-0", {label: "zero", detail: "_"}),
		]), datasets[0].characters[0]);
		assertSameCharacter(new Character("myd-1", null, {label: "Bobo", detail: "_"}, []), datasets[0].characters[1]);
		assertSameCharacter(new Character("myd-2", null, {label: "Just because", detail: "_"}, []), datasets[0].characters[2]);
		assertSameCharacter(new Character("myd-3", null, {label: "Poum", detail: "_"}, []), datasets[0].characters[3]);
		assertSameCharacter(new Character("myd-4", null, {label: "and yet", detail: "_"}, [
			new State("s3481592861683651", "myd-4", {label: "one for the road", detail: "_"})
		]), datasets[0].characters[4]);
	}
}
