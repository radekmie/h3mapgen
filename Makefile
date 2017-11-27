CXX = g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
LDLIBS =
TARGETS = components/ca/ca components/voronoi/voronoi

.PHONY: homm3lua

all: $(TARGETS) | homm3lua

components/ca/ca: Makefile components/ca/board.o components/ca/cellular_terrain.o components/ca/main.cpp
	 $(CXX) $(CXXFLAGS) -o components/ca/ca components/ca/*.o components/ca/main.cpp

components/voronoi/voronoi: Makefile components/voronoi/Constants.o components/voronoi/Sector.o components/voronoi/Tile.o components/voronoi/TileDivider.o components/voronoi/SectorLoader.o components/voronoi/BresenhamSectorLoader.o components/voronoi/ExactSectorLoader.o components/voronoi/Main.cpp
	$(CXX) $(CXXFLAGS) -o components/voronoi/voronoi components/voronoi/*.o components/voronoi/Main.cpp

clean:
	$(MAKE) -C libs/homm3lua clean
	rm -f components/ca/*.o components/voronoi/*.o
	rm -rf output

distclean: clean
	rm -f $(TARGETS)

homm3lua:
	$(MAKE) -C libs/homm3lua
