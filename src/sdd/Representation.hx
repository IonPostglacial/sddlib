package sdd;

@:structInit
class Representation {
	public var label:String;
	public var detail:String;
	public var mediaObjectsRefs:Array<MediaObjectRef> = [];

	public inline function new(label, detail, ?mediaObjectsRefs) {
		this.label = label;
		this.detail = detail;
		if (mediaObjectsRefs != null)
			this.mediaObjectsRefs = mediaObjectsRefs;
	}

	static inline function nullOrEmpty(s:String)
		return s == null || s == "";

	public static inline function assign(r1:Representation, r2:Null<Representation>) {
		if (r2 == null)
			return;
		if (!nullOrEmpty(r2.label))
			r1.label = r2.label;
		if (!nullOrEmpty(r2.detail))
			r1.detail = r2.detail;
		if (r2.mediaObjectsRefs != null && r2.mediaObjectsRefs.length > 0)
			r1.mediaObjectsRefs = r2.mediaObjectsRefs;
	}
}
