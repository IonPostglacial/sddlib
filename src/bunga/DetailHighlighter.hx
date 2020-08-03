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
        for (taxon in taxons) {
            for (word in wordsToHighlight) {
                taxon.detail = new EReg ('([^\\w])($word)([^\\w])', "g").replace(taxon.detail, '$1<b>$2</b>$3');
            }
        }
    }
}