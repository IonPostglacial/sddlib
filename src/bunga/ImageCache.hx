package bunga;

import js.html.XMLHttpRequest;
import js.html.Blob;
import js.html.idb.Database;
import js.Browser;
import js.lib.Promise;

typedef CacheEntry = {
    var url:String;
    var blob:Blob;
}

@:keep
@:expose
class ImageCache {
    static inline final DB_NAME = "ImageCache";
    static inline final DB_VERSION = 1;

    var cache = new Map<String, Blob>();

    public function new() {

    }

    function createStore(db: Database) {
        if (!db.objectStoreNames.contains("ImageCache")) {
            db.createObjectStore("ImageCache", { keyPath: "url" });
        }
    }

    function dbStore(url: String, blob: Blob) {
        final rq = Browser.window.indexedDB.open(DB_NAME, DB_VERSION);
        rq.onupgradeneeded = function () {
            createStore(rq.result);
        };
        rq.onerror = function () {
            trace("Impossible to store data on your browser.");
        };
        rq.onsuccess = function () {
            final db:Database = rq.result;

            final transaction = db.transaction("ImageCache", READWRITE);
            
            transaction.oncomplete = function () {
                // TODO: Handle success, error
                trace('Write for URL #${url} successful');
            };
        
            final ImageCache = transaction.objectStore("ImageCache");

            ImageCache.put({ url: url, image: blob }); // TODO: Handle success, error
        }
    }

    function dbList() {
        return new Promise(function (resolve, reject) {
            final rq = Browser.window.indexedDB.open(DB_NAME, DB_VERSION);
            rq.onupgradeneeded = function () {
                createStore(rq.result);
            };
            rq.onsuccess = function () {
                final db:Database = rq.result;

                final transaction = db.transaction("ImageCache", READONLY);
                
                transaction.oncomplete = function () {
                    // TODO: Handle success, error
                    trace("Listing ImageCache URLs successful");
                };
            
                final imageCache = transaction.objectStore("ImageCache");

                final list = imageCache.getAll();

                list.onsuccess = function () {
                    resolve(list.result);
                };
                list.onerror = function () {
                    trace("Listing ImageCache URLs failed.");
                    reject(rq.result);
                };
            };
            rq.onerror = function () {
                reject(rq.result);
            };
        });
    }

    function dbLoad(id) {
        return new Promise(function (resolve, reject) {
            final rq = Browser.window.indexedDB.open(DB_NAME, DB_VERSION);
            rq.onupgradeneeded = function () {
                createStore(rq.result);
            };
            rq.onsuccess = function () {
                final db:Database = rq.result;

                final transaction = db.transaction("ImageCache", READONLY);
                
                transaction.oncomplete = function () {
                    // TODO: Handle success, error
                    trace('Read from dataset #${id} successful');
                };
            
                final ImageCache = transaction.objectStore("ImageCache");

                final read = ImageCache.get(id);
                read.onsuccess = function () {
                    resolve(read.result);
                };
                read.onerror = function () {
                    trace('Read from dataset #${id} failed');
                    reject(read.result);
                };
            };
            rq.onerror = function () {
                reject(rq.result);
            };
        });
    }

    public function initFromDatabase() {
        return dbList().then(function (data:Array<CacheEntry>) {
            for (entry in data) {
                cache.set(entry.url, entry.blob);
            }
        });
    }

    public function addFromUrl(url: String) {
        final rq = new XMLHttpRequest();
        rq.open("GET", url);
        rq.responseType = BLOB;
        rq.onload = function (data) {
            cache.set(url, rq.response);
            trace(rq.response);
        };
        rq.send();
    }

    public function get(url: String):Blob {
        return cache[url];
    }
}