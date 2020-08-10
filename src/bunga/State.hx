package bunga;

import haxe.DynamicAccess;

@:structInit
class SddStateData {
    public var state:sdd.State;
    public var mediaObjects:Array<sdd.MediaObject>;
}

@:structInit
class State {
    public var id:String;
    public var descriptorId:String;
    public var name:String;
    public var photos:Array<String>;

    public static function fromSdd(state:sdd.State, photosByRef:DynamicAccess<String>):State {
        return {
            id: state.id,
            descriptorId: state.characterId,
            name: state.label,
            photos: state.mediaObjectsRefs.map(m -> photosByRef[m.ref]),
        };
    }

    public static function toSdd(state:State):SddStateData {
        return {
            state: {
                id: state.id,
                characterId: state.descriptorId,
                representation: {
                    label: state.name,
                    detail: "",
                    mediaObjectsRefs: [],
                }
            },
            mediaObjects: [],
        }
    }
}