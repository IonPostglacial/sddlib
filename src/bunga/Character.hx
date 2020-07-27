package bunga;

import haxe.DynamicAccess;

@:keep
@:expose
@:structInit
class Character extends HierarchicalItem {
    public var states:Array<State>;
    public var inapplicableStates:Array<State>;

    public inline function new(id, hid, parentId, topLevel, children, data: DetailData, states:Array<State>, inapplicableStates:Array<State>) {
        super("character", id, hid, parentId, topLevel, children, data);
        this.states = states;
        this.inapplicableStates = inapplicableStates;
    }

    public static function fromSdd(character:sdd.Character, photosByRef:DynamicAccess<String>, statesById:DynamicAccess<State>):Character {
        return {
            id: character.id,
            hid: character.id,
            parentId: character.parentId,
            topLevel: character.parentId == null,
            children: character.childrenIds,
            data: DetailData.fromRepresentation(character, [], photosByRef),
            states: character.states.map(s -> statesById[s.id]),
            inapplicableStates: character.inapplicableStatesRefs.map(s -> statesById[s.ref]),
        };
    }
}