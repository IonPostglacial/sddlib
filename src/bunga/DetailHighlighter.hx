package bunga;

import haxe.DynamicAccess;
using StringTools;

@:keep
@:expose
class DetailHighlighter {
    var wordsToHighlight:Array<String> = [];

    public function new() {}

    public function loadWordText(text:String) {
        final lines = text.split("\n");
        for (line in lines) {
            final words = line.split(",");
            for (word in words) {
                wordsToHighlight.push(word.trim());
            }
        }
    }

    public function highlightTaxons(taxons:DynamicAccess<Taxon>) {
        var reTxt = wordsToHighlight.map(word -> ERegTools.escape(word)).join("|");
        var re = new EReg('([^\\w<>]|^|<p>)($reTxt)([^\\w<>]|$|</p>)', "g");
        for (taxon in taxons) {
            taxon.detail = re.replace(taxon.detail, '$1<b>$2</b>$3');
        }
    }
}