# params

Handles parameters given by the user (usually by gui) and config, producing concrete generation values and initial node for LML phase.

### Obsługa features:

- `WxH` map size: Na razie nie
- Woda (płytka): Na razie nie, ale wysoki priorytet
- Woda (wysoka, wiry): Na razie nie
- Teleporty: Będą
- Warunek zwycięstwa Town Capture: Będzie
- Pozostałe warunki zwycięstwa: Na razie nie (poza graalem zależą od dużo dalszych komponentów)
- Stawianie Graala: Po stronie parametrów chyba zrobię, ale ogólnie to będzie w jakimś późniejszym komponencie


## Input/output specification

Component main function `TODO(h3pgm)` reads map as `h3pgm` table, and modifies it by adding new elements. 


### input 

- `config` - content of user's [config.cfg](../../config.cfg) file
- `paramsGeneral` - parameters specifying map provided by the user: [detailed specification](GeneralParams.md)
- `paramsDetailedUser` - user-provided values overriding (maybe partially) `detailedParams` (but `detailedParams` are always computed to ensure the system is deterministic). Additionally, [`seed`](GeneralParams.md#seedint) value cannot be override this way.

### output

- `paramsDetailed` - concretization of `paramsGeneral` (if random inputted) plus additional values computed based on that parameters: [detailed specification](DetailedParams.md). If user provides non-empty `paramsDetailedUser`, his values always (except for `seed`) override the generated ones.
- `lmlInitialNode` - initial node of the LML graph, containing all classes and map features (see [LML specification](../mlml/README.md))

