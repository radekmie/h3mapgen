CXX = g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
LDLIBS =
TARGETS = cellular/cellular bin/voronoi

.PHONY: homm3lua

all: $(TARGETS) | homm3lua

cellular/cellular: Makefile cellular/board.o cellular/cellular_terrain.o cellular/main.cpp
	 $(CXX) $(CXXFLAGS) -o cellular/cellular cellular/*.o cellular/main.cpp

bin/voronoi: Makefile src/voronoi/Constants.o src/voronoi/Sector.o src/voronoi/Tile.o src/voronoi/TileDivider.o src/voronoi/SectorLoader.o src/voronoi/BresenhamSectorLoader.o src/voronoi/ExactSectorLoader.o src/voronoi/Main.cpp
	$(CXX) $(CXXFLAGS) -o bin/voronoi src/voronoi/*.o src/voronoi/Main.cpp

clean:
	$(MAKE) -C homm3lua clean
	rm -rf output
	find ./src -depth -name *.o -delete
	find ./cellular -depth -name *.o -delete

distclean: clean
	rm -f $(TARGETS)

homm3lua:
	$(MAKE) -C homm3lua
