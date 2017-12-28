CXX = g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
ARMAFLAGS = -O2 -DARMA_DONT_USE_WRAPPER -DARMA_USE_BLAS -DARMA_USE_LAPACK -lopenblas -llapack
LDLIBS =
TARGETS = components/ca/ca components/voronoi/voronoi components/mds/mds

.PHONY: homm3lua

all: $(TARGETS) | homm3lua

components/ca/ca: Makefile components/ca/board.o components/ca/cellular_terrain.o components/ca/main.cpp
	$(CXX) $(CXXFLAGS) -o components/ca/ca components/ca/*.o components/ca/main.cpp

components/voronoi/voronoi: Makefile components/voronoi/Constants.o components/voronoi/Sector.o components/voronoi/Tile.o components/voronoi/TileDivider.o components/voronoi/SectorLoader.o components/voronoi/BresenhamSectorLoader.o components/voronoi/ExactSectorLoader.o components/voronoi/Main.cpp
	$(CXX) $(CXXFLAGS) -o components/voronoi/voronoi components/voronoi/*.o components/voronoi/Main.cpp

components/mds/mds: Makefile components/mds/graph.o components/mds/min_bounding_rect.o components/mds/sammon.o components/mds/qhull_2d.o components/mds/postproc.o components/mds/main.cpp
	$(CXX) $(CXXFLAGS) $(ARMAFLAGS) -o components/mds/mds components/mds/*.o components/mds/main.cpp

clean:
	$(MAKE) -C libs/homm3lua clean
	rm -f components/ca/*.o components/voronoi/*.o components/mds/*.o
	rm -rf output

distclean: clean
	rm -f $(TARGETS)

homm3lua:
	$(MAKE) -C libs/homm3lua
