package bunga;

import sdd.MediaObject;
import haxe.DynamicAccess;
using Lambda;

@:structInit
class SddCharacterData {
	public var character:sdd.Character;
	public var states:Array<sdd.State>;
	public var mediaObjects:Array<sdd.MediaObject>;
}

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

	public static function toSdd(character:Character, extraFields:Array<Field>, mediaObjects:Array<MediaObject>):SddCharacterData {
		final statesData = character.states.map(s -> State.toSdd(s));
		final states = statesData.map(data -> data.state);
		return {
			character: {
				id: character.id,
				parentId: character.parentId,
				representation: character.toRepresentation(extraFields),
				states: states,
				inapplicableStatesRefs: character.inapplicableStates.map(s -> new sdd.StateRef(s.id)),
				childrenIds: character.children.keys(),
			},
			states: states,
			mediaObjects: statesData.flatMap(data -> data.mediaObjects).concat([]),
		};
	}
}
