package bunga;

import haxe.io.BytesData;
import js.lib.Promise;
import haxe.io.Bytes;
import haxe.crypto.Crc32;
import haxe.io.BytesOutput;
import haxe.zip.Writer;

using StringTools;

@:keep
@:expose
class TaxonToTex {
    var photos:Array<String>;
    var pictureNameByUrl:Map<String, String>;
    var progressListeners:Array<(progress:Int, progressMax:Int)->Void>;

    public function new(taxons:Array<Taxon>) {
        progressListeners = [];
        pictureNameByUrl = [];
        photos = [];
        for (taxon in taxons) {
            if (taxon.photos.length > 0) {
                final photo = taxon.photos[0];
                pictureNameByUrl.set(photo, FileNameGenerator.generate(taxon.name) + ".jpg");
                photos.push(photo);
            }
        }
    }

    @:keep public function picture(resolve:(code:String) -> Dynamic, urls:Array<String>) {
        return pictureNameByUrl[urls[0]];
    }

    public function onProgress(listener:(progress:Int, progressMax:Int)->Void) {
        progressListeners.push(listener);
    }

    function progressed(progress:Int, progresMax:Int) {
        for (listener in progressListeners) {
            listener(progress, progresMax);
        }
    }

    public function export(taxons:Array<Taxon>):Promise<BytesData> {
        final texTemplate = haxe.Resource.getString("tex_template");
        final template = new haxe.Template(texTemplate);
        final entries = new List<haxe.zip.Entry>();

        final texFileContent = Bytes.ofString(template.execute({taxons: taxons}, this));

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
                semaphore--;
                progressed(photos.length - semaphore, photos.length);
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