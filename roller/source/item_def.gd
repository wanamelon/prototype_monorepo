class_name ItemDef extends Resource

enum ItemId {
	ADD_STAMINA,
	SPEED_BUFF_ON_DESTROY,
	SPAWN_RANDOM_TILE_OBJECT,
	LEVEL_UP_ITEM_ON_TOUCH,
	SPAWN_BOUNCE_PILLAR,
	INCREASE_SIZE
}

@export var item_id: ItemId
