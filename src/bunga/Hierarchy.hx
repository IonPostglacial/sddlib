package bunga;

import haxe.crypto.Base64;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.DynamicAccess;
import haxe.io.BytesOutput;
import haxe.zip.Writer;

using StringTools;

typedef HierarchyEntry = {
    var id:Int;
    var name:String;
    var topLevel:Bool;
    var children:DynamicAccess<HierarchyEntry>;
}

@:keep
@:expose
class Hierarchy {
    static var forbiddenChars = [" ", "*", ".", '"', "/", "\\", "[", "]", ":", ";", "|", ","];

    static function getEntries(hierarchy:DynamicAccess<HierarchyEntry>, ?entries:List<haxe.zip.Entry> = null, ?path=""):List<haxe.zip.Entry> {
        if (hierarchy == null) return new List();
        if (entries == null) entries = new List<haxe.zip.Entry>();
        final content = Bytes.ofString("");
        
        for(entry in hierarchy) {
            if (entry.topLevel || path != "") {
                var entryName = entry.name;
                for (char in forbiddenChars) {
                    entryName = entryName.replace(char, "_");
                }
                final currentPath = path + entryName.urlEncode() + "/";
                entries.push({
                    fileName: currentPath, 
                    fileSize: content.length,
                    fileTime: Date.now(),
                    compressed: false,
                    dataSize: 0,
                    data: content,
                    crc32: Crc32.make(content),
                });
                getEntries(entry.children, entries, currentPath);
            }
        }
        return entries;
    }

    public static function toZip(hierarchy:DynamicAccess<HierarchyEntry>):String {
        final entries = getEntries(hierarchy);
        final bytes = new BytesOutput();
        final writer = new Writer(bytes);
        writer.write(entries);
        return Base64.encode(bytes.getBytes());
    }
}
