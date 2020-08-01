package bunga;

import haxe.DynamicAccess;

@:structInit
class Character extends HierarchicalItem<Character> {
	public var states:Array<State>;
	public var inapplicableStates:Array<State>;

	public inline function new(item:HierarchicalItem<Character>, states:Array<State>, inapplicableStates:Array<State>) {
		super("character", item.id, item.hid, item.parentId, item.topLevel, item.children.keys(), item);
		this.states = states;
		this.inapplicableStates = inapplicableStates;
	}

	public static function fromSdd(character:sdd.Character, photosByRef:DynamicAccess<String>, statesById:DynamicAccess<State>):Character {
		return {
			item: {
				type: "character",
				id: character.id,
				hid: character.id,
				parentId: character.parentId,
				topLevel: character.parentId == null,
				childrenIds: character.childrenIds,
				data: DetailData.fromRepresentation(character, [], photosByRef),
			},
			states: character.states.map(s -> statesById[s.id]),
			inapplicableStates: character.inapplicableStatesRefs.map(s -> statesById[s.ref]),
		};
	}
}
