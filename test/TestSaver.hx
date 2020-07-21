import utest.Assert;
import utest.Test;

class TestSaver extends Test {
    function testLoadSaveCycle() {
		final loader = new sdd.Loader();
		final sddSample = haxe.Resource.getString("sdd_sample");
        final datasets = loader.load(sddSample);
        final saver = new sdd.Saver(datasets);
        final savedSample = saver.save();
        final savedDataset = loader.load(savedSample);

        Assert.same(datasets, savedDataset);
    }
}