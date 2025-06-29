#region Direction
enum DIR
{
	UP = 90,
	DOWN = 270,
	LEFT = 180,
	RIGHT = 0
}
#endregion

#region Depth
enum DEPTH_UI
{
	PANEL = -100,
	TEXT = -200,
	ENCOUNTER_ANIM = -300,
	FADER = -400,
}

enum DEPTH_BATTLE
{
	BG = -100,
	ENEMY = -200,
	BOARD = -300,
	UI = -400,
	BULLET_LOW = -500,
	UI_HIGH = -600,
	BULLET_MID = -700,
	SOUL = -800,
	BULLET_HIGH = -900,
	FADER = -1000,
}
#endregion

#region Battle Enums (better not touching)
enum BATTLE_STATE
{
	MENU,
	DIALOG,
	TURN_PREPARATION,
	IN_TURN,
	BOARD_RESETTING,
	RESULT,
}

enum BATTLE_MENU
{
	BUTTON,
	FIGHT_TARGET,
	FIGHT_AIM,
	FIGHT_ANIM,
	FIGHT_DAMAGE,
	ACT_TARGET,
	ACT_ACTION,
	ITEM,
	MERCY,
}

enum BATTLE_BUTTON
{
	FIGHT,
	ACT,
	ITEM,
	MERCY,
}
	
enum BATTLE_MENU_ITEM
{
	HORIZONTAL,		// Default UNDERTALE item bar
	VERTICAL,		// Depends on preferences (In UNDERTALE Japanese language setting use this)
}

enum BATTLE_MENU_CHOICE_BUTTON
{
	FIGHT,
	ACT,
	ITEM,
	MERCY,
}

enum BATTLE_MENU_CHOICE_MERCY
{
	SPARE,
	FLEE,
}

enum BATTLE_ENEMY_EVENT
{
	INIT,
	BATTLE_START,
	MENU_START,
	MENU_SWITCH,
	MENU_CHOICE_SWITCH,
	MENU_END,
	DIALOG_START,
	DIALOG_END,
	TURN_PREPARATION_START,
	TURN_PREPARATION_END,
	TURN_START,
	TURN_END,
	BOARD_RESETTING_START,
	BOARD_RESETTING_END,
}

enum BATTLE_SOUL_EVENT
{
	BULLET_COLLISION,
	HURT,
}

enum BATTLE_BULLET_EVENT
{
	SOUL_COLLISION,
	TURN_END,
}

enum BATTLE_TURN_EVENT
{
	TURN_PREPARATION_START,
	TURN_PREPARATION_END,
	TURN_START,
	TURN_END,
}

enum BATTLE_BOARD
{
	X = 320,
	Y = 320,
	UP = 65,
	DOWN = 65,
	LEFT = 283,
	RIGHT = 283
}

enum BATTLE_TURN
{
	TIME,
	BOARD_X,
	BOARD_Y,
	BOARD_UP,
	BOARD_DOWN,
	BOARD_LEFT,
	BOARD_RIGHT,
	BOARD_MOVE_EASE,
	BOARD_MOVE_MODE,
	BOARD_MOVE_SPEED,
	BOARD_MOVE_DURATION,
	BOARD_SIZE_EASE,
	BOARD_SIZE_MODE,
	BOARD_SIZE_SPEED,
	BOARD_SIZE_DURATION,
	BOARD_RESET_X,
	BOARD_RESET_Y,
	BOARD_RESET_UP,
	BOARD_RESET_DOWN,
	BOARD_RESET_LEFT,
	BOARD_RESET_RIGHT,
	BOARD_RESET_MOVE_EASE,
	BOARD_RESET_MOVE_MODE,
	BOARD_RESET_MOVE_SPEED,
	BOARD_RESET_MOVE_DURATION,
	BOARD_RESET_SIZE_EASE,
	BOARD_RESET_SIZE_MODE,
	BOARD_RESET_SIZE_SPEED,
	BOARD_RESET_SIZE_DURATION,
	SOUL_X,
	SOUL_Y,
	BOARD_ROT,
	BOARD_ROT_EASE,
	BOARD_ROT_MODE,
	BOARD_ROT_SPEED,
	BOARD_ROT_DURATION,
	BOARD_RESET_ROT,
	BOARD_RESET_ROT_EASE,
	BOARD_RESET_ROT_MODE,
	BOARD_RESET_ROT_SPEED,
	BOARD_RESET_ROT_DURATION
}

enum BATTLE_TURN_BOARD_TRANSFORM_MODE
{
	SPEED,
	DURATION,
}	
#endregion

#region Flag
/*-----------------------------------------------------------------*/
#region Types
enum FLAG_TYPE
{
	STATIC,
	DYNAMIC,
	TEMP,
	INFO,
	SETTINGS,
}
#endregion
	
#region Static
enum FLAG_STATIC
{
	NAME,
	LV,
	HP_MAX,
	HP,
	ATK,
	ATK_ITEM,
	DEF,
	DEF_ITEM,
	SPD,
	SPD_ITEM,
	INV,
	INV_ITEM,
	EXP,
	GOLD,
	ITEM,
	ITEM_WEAPON,
	ITEM_ARMOR,
	CELL,
	PLOT,
	MURDER_LV,
	KILLS,
	ROOM,
	TIME,
	BOX,
}
#endregion

#region Dynamic
enum FLAG_DYNAMIC
{
			
}
#endregion

#region Temp
enum FLAG_TEMP
{
	FUN,
	SAVE_SLOT,
	ENCOUNTER,
	BATTLE_ROOM_RETURN,
	GAMEOVER_SOUL_X,
	GAMEOVER_SOUL_Y,
	TRIGGER_WARP_LANDMARK,
	TRIGGER_WARP_DIR,
	TEXTWRITER_CHOICE,
	KR,
}
#endregion

#region Info
enum FLAG_INFO
{
	NAME,
	LV,
	TIME,
	ROOM,
}
#endregion

#region Settings
enum FLAG_SETTINGS
{
	LANGUAGE,
	VOLUME,
	BORDER
}
#endregion
/*-----------------------------------------------------------------*/
#endregion

#region Plot (idk what this do)
enum PLOT
{
	START,
}
#endregion

#region Soul
enum SOUL
{
	RED = 1,
	BLUE = 2,
}
#endregion

#region Bone
enum BONE
{
	VERTICAL = 90,
	HORIZONTAL = 0,
	WHITE = 0,
	BLUE = 1,
	ORANGE = 2,
}
#endregion

#region Sans
enum SANS_ACTION
{
	STATIC = -1,
	IDLE,
	LEFT,
	RIGHT,
	UP,
	DOWN,
	HURT,
}
#endregion