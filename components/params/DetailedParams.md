# `paramsDetailed` specification

Apart from concretization of `paramsGeneral`, `paramsDetailed` should contain values directly influencing process of initializing LML (including priorities of some specialized productions!) and other processes in later steps of the generator. However, specifying them directly here allow users to manipulate them easier. Sketch of the influence mapping from `paramsGeneral` to some of the more detailed map features [here](../../docs/17.02.01-MapParams-2.jpg).

### _param ∈ userMapParams_

All keys given in [`paramsGeneral`](GeneralParams.md) are available in `paramsDetailed`. If user's choice was not _Random_ option, the parameter value is copied. If it was _Random_, its value is randomized over the valid values for this parameter.

There is a special treatment of `players[p].castles` where, if table of length > 1 is provided, the value become string (randomized over the proposed castles). If table length is 0 (in-game random castle), its value in `paramsDetailed` is `nil`.

After the generation, the values, except `seed`, are overridden by the content of `paramsDetailedUser` table.


### `width`:int
Width of the map in squares (36, 72, 108, 144)

### `height`:int
Height of the map, works the same as width.

### `difficulty`:string
Based on the `monsters`, `welfare`, and `locations` estimates the difficulty of the map (as set in the map editor).
Possible difficulty values are: `"Easy"`, `"Normal"`, `"Hard"`, `"Expert"`, `"Impossible"`.

### `zoneSide`:int
Used to estimated size of each zone assuming it is a square of this side. The size increases with map size. Also it is influenced by the `zonesize` parameter and config settings.

### `zonesnum`:table
Contains information for LML/MultiLML about the number local/buffer zones. Depends on map `size`, `underground`, number of `players`, `zoneSide` and some magic formulas.

- `estimAll`:int - Estimation for the desired number of all zones in MultiLML
- `singleLocal`:int - Number of local zones in LML
- `singleBuffer`:int -  Number of buffer zones in LML









## Not implemented


### _playerTowns_:int
_Number of towns owned by the player at the beginning of the game._


=================



### _todo_

- number of zones (water?)
- levels of zones 
- production priorities
- number of obelisks
- ...


