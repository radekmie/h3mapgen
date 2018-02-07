# `LML Graph` specification


## `graph`:object

Encodes LML graph, i.e. its nodes are zones, and (undirected) edges means connections between the zones. 

Zones are stored as [`zone`](#zoneobject) objects treating the graph as normal table. Zone's id is its position in the table.


### `edges`:table

Connections between zones stored as two-dimension adjacency table with zones' ids as keys. 




## `zone`:object

Zone contains information about some logical region of the map. Eventaully, this should be zone's class and a set of features consistent with this class. 

During the computation the graph node representing zone may contain multiple classes and various features. However, it always has to be _consistent_, i.e. it cannot contain feature for class not belonging to the zone. We say the zone is _final_ when it is consistent and contain exactly one class.


### `classes`:table

List of all classes assigned to the zone. Final zones contain only one class.

### `features`:table

List of all features within the zone. The features in the list have to be consistent with zones classes.



## `feature`:object

Describes heavy feature on map: town or mine; or connection with the other player.
Feature is always paired with some [class](#classobject), meaning it can be placed only within a zone of this class.

### `class`:table

Class of zone the feature should be within.


### `type`:string

Defines type of the feature. It can be one of the following:

- `"OUTER"` - Edge that connect the zone to other player's (single) graph. If one zone contains multiple outers they should all point out different players' graphs.
- `"TOWN"` - Puts town in the zone.
- `"MINE"` - Puts mine in the zone.

### `value`:int/string

Value of the feature, depending on its type.

##### For `"OUTER"` (int):

Level of the outer edge. Semantics of the level is the same as for [class.level](#levelint). The final edge level, after creating MultiLML, is the maximum of outer feature level and both connected zones.

##### For `"TOWN"` (string):

- `"MAIN"` - Main tow for the player, only one such town should exist in the graph.
- `"PLAYER"` - Belongs to the player from the beginning, same type as player's race.
- `"RACE"` - If in local zone, town of the player's race. If in buffer, random *not* adjacent player's races (if not possible - then like `NEUTRAL`).
- `"NEUTRAL"` - Random town (but defined in generator phase).
- `"RANDOM"` - In-game random town.

_Pytanie: Nie jest tych kategorii trochę za dużo...?_

##### For `"MINE"` (string):

- `"BASE"` - In this zone **both** mines should be placed: Sawmill and Ore Pit.
- `"PRIMARY"` - In this zone **two** mines, should be placed. Mapping from race to mine type is defined in [config.cfg](../../../config.cfg). If the zone contains a castle, primary mines for this castle should be taken. Otherwise, if the zone is LOCAL, player's primary mines should be taken. Otherwise there should be warning(?) and it should work as `"RANDOM"` option.
- `"GOLD"` - Places a single Gold Mine.
- `"RANDOM"` - Places a single, random mine, depending on zone's level and type (and also player race if local? _to trochę dużo opcji by było..._). Settings are taken from [config.cfg](../../../config.cfg) file

_Pytanie: jak późno możemy ustawić konkretne kopalnie? Pomimo, że są jako obiekty podobne to niestety nieznacznie się różnią, zwłaszcza drewno, a fajnie byłoby móc to sobie przelosować na końcowym etapie tworzenia mapy._






## `class`:object

Encodes purpose and difficulty lever for each zone/feature. Thus it points what kinds of objects should be placed within such zone. 

Classes are equal if their `type` and `level` are equal.

### `type`:string

Defines purpose of the zone from the strategic point of view.

- `"LOCAL"` - The zone should 'belong to the player' in the sense that it has lower difficulty passage to it than his opponents.
- `"BUFFER"` - The zone with equally difficult path to get to by more than one player.
- `"GOAL"` - Special zone for some types of [winning conditions](../../params/UserMapParams.md#winningint). There has to be at most one on the map.
- `"TELEPORT"` - A zero-space zone, teleport is in fact a multiedge than can connect both local and buffer zones together.
- `"WATER"` - Special type of BUFFER zone. **Not implemented**

All zones except `"LOCAL"` are treated as non-LOCAL. 
The ordering on zones goes as follows: `LOCAL < TELEPORT < BUFFER = WATER < GOAL`

### `level`:int

The higher level of zone the more difficult monsters should be inside (and more rewarding buildings/resources).

Minimal zone level is 1, maximal level is set in `MaxZoneLevel` field in [config.cfg](../../../config.cfg).

Levels should have predefined semantics (as 1: level 1-2 creatures, 2 - level 3-3 creatures, ..., level 10 - hundreds of level 4 creatures), but we should also try to make it dynamic, so one could set higher or lower max level.

_OK, nie wiem jak to będzie w praktyce, na razie przyjmujemy 10 max_


