CXX ?= g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
LDLIBS =
TARGETS = cellular/cellular bin/voronoi

all: bin/voronoi | cellular/cellular homm3lua

.PHONY: clean
clean:
	$(MAKE) -C homm3lua clean
	$(MAKE) -C cellular clean
	rm -rf output
	find ./src -depth -name *.o -delete

.PHONY: distclean
distclean: clean
	$(MAKE) -C cellular distclean
	rm -f $(TARGETS)

.PHONY: cellular/cellular
cellular/cellular:
	$(MAKE) -C cellular

bin/voronoi: Makefile src/voronoi/Constants.o src/voronoi/Sector.o src/voronoi/Tile.o src/voronoi/TileDivider.o src/voronoi/SectorLoader.o src/voronoi/BresenhamSectorLoader.o src/voronoi/ExactSectorLoader.o src/voronoi/Main.cpp
	$(CXX) $(CXXFLAGS) -o bin/voronoi src/voronoi/*.o src/voronoi/Main.cpp

.PHONY: homm3lua
homm3lua:
	$(MAKE) -C homm3lua
