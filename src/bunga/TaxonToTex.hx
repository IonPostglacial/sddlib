package bunga;

import haxe.io.BytesData;
import js.lib.Promise;
import haxe.io.Path;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.Crc32;
import haxe.io.BytesOutput;
import haxe.zip.Writer;

using StringTools;

@:keep
class TTMacro {
    var pictureNameByUrl:Map<String,String>;
    public function new(pictureNameByUrl) {
        this.pictureNameByUrl = pictureNameByUrl;
    }

    @:keep public function picture(resolve:(code:String) -> Dynamic, urls:Array<String>) {
        return pictureNameByUrl[urls[0]];
    }
}

@:keep
@:expose
class TaxonToTex {
    public static function export(taxons:Array<Taxon>):Promise<BytesData> {
        final texTemplate = haxe.Resource.getString("tex_template");
        final template = new haxe.Template(texTemplate);
        final entries = new List<haxe.zip.Entry>();
        final pictureNameByUrl = new Map<String, String>();

        final photos = [];
        for (taxon in taxons) {
            if (taxon.photos.length > 0) {
                final photo = taxon.photos[0];
                pictureNameByUrl.set(photo, FileNameGenerator.generate(taxon.name) + ".jpg");
                photos.push(photo);
            }
        }

        final texFileContent = Bytes.ofString(template.execute({taxons: taxons}, new TTMacro(pictureNameByUrl)));

        entries.push({
            fileName: "latex/export.tex", 
            fileSize: texFileContent.length,
            fileTime: Date.now(),
            compressed: false,
            dataSize: 0,
            data: texFileContent,
            crc32: Crc32.make(texFileContent),
        });

        return new Promise(function (resolve, reject) {
            var semaphore = photos.length;

            function semDec() {
                trace('dec: $semaphore');
                semaphore--;
                if (semaphore == 0) {
                    final bytes = new BytesOutput();
                    final writer = new Writer(bytes);
                    writer.write(entries);
                    resolve(bytes.getBytes().getData());
                }
            }

            for (photo in photos) {
                final rq = new haxe.Http(photo);
                rq.onBytes = function (bytes) {
                    entries.push({
                        fileName: "latex/" + pictureNameByUrl.get(photo),
                        fileSize: bytes.length,
                        fileTime: Date.now(),
                        compressed: false,
                        dataSize: 0,
                        data: bytes,
                        crc32: Crc32.make(bytes),
                    });
                    semDec();
                }
                rq.onError = function (msg) {
                    trace('error: $msg');
                    semDec();
                };
                rq.request(false);
            }
        });
    }
}