# `detailedParams` specification

Apart from concretization of `userParameters`, `detailedParams` should contain values directly influencing process of initializing LML (including priorities of some specialized productions!) and other processes in later steps of the generator. However, specifying them directly here allow users to manipulate them easier. Sketch of the influence mapping from `userMapParams` to some of the more detailed map features [here](../../docs/17.02.01-MapParams-2.jpg).

### _param ∈ userMapParams_

All keys given in [`userMapParams`](#UserMapParams.md) are available in `detailedParams`. If user's choice was not _Random_ option, the parameter value is copied. If it was _Random_, its value is randomized over the valid values for this parameter.

There is a special treatment of `players[p].castles` where, if table of length > 1 is provided, the value become string (randomized over the proposed castles). If table length is 0 (in-game random castle), its value in `detailedParams` is `nil`.

After the generation, the values, except `seed`, are overridden by the content of `userDetailedParams` table.

### _playerTowns_:int
_Number of towns owned by the player at the beginning of the game._


=================

- width
- height
- difficulty




### _todo_

- number of zones (all, water, local, buffer)
- levels of zones 
- difficulty (easy, normal, Hard, Expert, Impossible) - as seen by the map editor  (moglibyśmy to dać ustawiać userowi, ale ma chyba wpływ tylko na random obiekty/potwory których raczej nie stawiamy, niech lepiej automatycznie wynika z innych parametrów)
- production priorities
- number of obelisks
- ...


