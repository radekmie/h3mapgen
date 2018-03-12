# `paramsGeneral` specification

Partially based on arrangements pictured [here](../../docs/17.02.01-MapParams-1.jpg).

### `version`:string
_**Map version**: Game version to generate map for._
<details>
  
- `"RoE"` - _Restoration of Erathia_
- `"SoD"` - _Shadow of Death_
</details>

### `seed`:int
_**Generation seed**: Value "0" generates random map, provide other value if you want to reproduce a concrete output._

### `size`:string
_**Map size**: Size of the map._
<details>
  
- `"S"` - _Small (36x36)_
- `"M"` - _Medium (72x72)_
- `"L"` - _Large (108x108)_
- `"XL"` - _Extra Large (144x144)_

(future feature: in theory we can allow any rectangular map size `WxH` smaller then 144x144)
</details>

### `underground`:bool
_**Two level map**: If checked the map will contain an underground level._

### `players`:table
_**Players**: Set the number and specifics of the players._
<details>
  
- _**Castle**: Choose castles available (randomized) for this player, check "random" to set town choosable at the beginning of a game_
- _**Team**: Choose a team number for the player_
- _**Computer only**: Set if the player should be AI only_

`Player = {id:int=1..8, team:int=1..8, computerOnly:bool, castle:table={"Castle", "Tower",...}/{} if in-game random}`
</details>
  
### `winning`:int
_**Winning condition**: The goal of the players._
<details>
  
- `0` - _Random_
- `1` - _Defeat all your enemies_
- `2` - _Capture Town_
- `3` - _Defeat Monster_
- `4` - _Acquire Artifact or Defeat All Enemies_
- `5` - _Build a Grail Structure or Defeat All Enemies_

(możemy się ograniczyć tylko do `1`, ale kurde, dotychczas żaden generator nie pozwalał na pozostałe, a chyba jesteśmy w stanie to zrobić) 
(z kolei z warunkami przegranej proponowałbym nie kombinować)
</details>
  
### `water`:int
_**Water level**: Influences proportion of map covered by the water._
<details>
  
- `0` - _Random_
- `1` - _None_
- `2` - _Low (lakes, seas)_
- `3` - _Standard (continents)_
- `4` - _High (islands)_
</details>
  
### `grail`:bool
_**Grail**: If checked the map will contain Grail._

### `towns`:int
_**Towns frequency**: Influences the number of towns placed on the map._
<details>
  
- `0` - _Random_
- `1` - _Very rare_
- `2` - _Rare_
- `3` - _Normal_
- `4` - _Common_
- `5` - _Very common_
</details>

### `monsters`:int
_**Monster Strength**: Influences the strength of monsters._
<details>
  
- `0` - _Random_
- `1` - _Very weak_
- `2` - _Weak_
- `3` - _Medium_
- `4` - _Strong_
- `5` - _Very strong_
</details>

### `welfare`:int
_**Welfare**: Influences the number of available resources, mines, artifacts, etc._
<details>
  
- `0` - _Random_
- `1` - _Very poor_
- `2` - _Poor_
- `3` - _Medium_
- `4` - _Rich_
- `5` - _Very rich_
</details>

### `branching`:int
_**Branching**: Influences the number of available routes between the map zones._
<details>

- `0` - _Random_
- `1` - _All zones contain as small number of entrances as possible_
- `2` - _Most zones contain only minimal number of entrances_
- `3` - _Some zones contain multiple entrances, some not_
- `4` - _Most zones contain multiple entrances_
- `5` - _All zones contain multiple entrances_
</details>
  
### `focus`:int
_**Challenge focus**: Influences the balance between fighting against environment (PvE) and fighting against other players (PvP)._
<details>
  
- `0` - _Random_
- `1` - _Strong PvP_
- `2` - _More PvP_
- `3` - _Balanced_
- `4` - _More PvE_
- `5` - _Strong PvE_
</details>
  
### `transitivity`:int
_**Transitivity**: Influences the number of obstacles and shapes of available paths within the zones._
<details>
  
- `0` - _Random_
- `1` - _Strongly mazelike zones_
- `2` - _More zones containing mazelike style_
- `3` - _Zones containing various styles_
- `4` - _More zones containing open terrain_
- `5` - _Strongly open terrain zones_
</details>
  
### `locations`:int
_**Locations frequency**: Influences the frequency of interactive adventure map locations (universities, arenas, creature banks, swan ponds, etc.)._
<details>
  
- `0` - _Random_
- `1` - _Very rare_
- `2` - _Rare_
- `3` - _Standard_
- `4` - _Common_
- `5` - _Very common_
</details>

### `zonesize`:int
_**Zone size**: Influences the size of an average zone._
<details>
  
- `0` - _Random_
- `1` - _Strongly decreased_
- `2` - _Decreased_
- `3` - _Standard_
- `4` - _Increased_
- `5` - _Strongly increased_
</details>
  
  
