package bunga;

import bunga.DetailData;
import haxe.DynamicAccess;

@:structInit
class HierarchicalItem extends Item {
	public var type:String;
	public var hid:String;
	public var parentId:Null<String>;
	public var topLevel:Bool;
	public var hidden = false;
	public var children:DynamicAccess<HierarchicalItem>;

	public function setEmptyChildren(childrenIds:Array<String>) {
		for (id in childrenIds) {
			children[id] = null;
		}
	}

	public function hydrateChildren(hierarchyById:DynamicAccess<HierarchicalItem>) {
		for (id in children.keys()) {
			final child = hierarchyById[id];
			if (child == null) {
				Reflect.deleteField(children, id);
				trace('Child not found: $name > $id');
			} else {
				children[id] = hierarchyById[id];
			}
		}
	}

	public inline function new(type, id, hid, parentId, topLevel, childrenIds:Array<String>, data:DetailData) {
		super(id, data);
		this.type = type;
		this.hid = hid;
		this.parentId = parentId;
		this.topLevel = topLevel;
		this.children = {};
		for (id in childrenIds) {
			children[id] = null;
		}
	}
}
