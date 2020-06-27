package sdd;

@:structInit
class Representation {
    public var name: String;
    public var detail: String;
    public var mediaObjects: Array<MediaObject> = [];

    static inline function nullOrEmpty(s: String) return s == null || s == "";

    public static inline function assign(r1: Representation, r2: Null<Representation>) {
        if (r2 == null) return;

        if (!nullOrEmpty(r2.name)) {
            r1.name = r2.name;
        }
        if (!nullOrEmpty(r2.detail)) {
            r1.detail = r2.detail;
        }
        if (r2.mediaObjects != null && r2.mediaObjects.length > 0) {
            r1.mediaObjects = r2.mediaObjects;
        }
    }
}