import sdd.Representation;
import bunga.DetailData;
import utest.Assert;
import utest.Test;

class TestDetailData extends Test {
	function testFromRepresentation() {
		final representation:Representation = {
			label: "A // B",
			detail: "NV: Hey<br><br>
				Flore Madagascar et Comores<br>
				fasc 6<br>
				page 24",
		}
		final data = DetailData.fromRepresentation(representation, [], {});
		Assert.equals("A", data.name);
		Assert.equals("B", data.nameCN);
		Assert.equals("Hey", data.vernacularName);
		Assert.equals(6, data.fasc);
		Assert.equals(24, data.page);
	}
}
