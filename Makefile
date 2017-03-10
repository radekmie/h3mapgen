CXX = g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
LDLIBS =
TARGETS = bin/cellular bin/cellular_terrain.o bin/board.o
 
all: $(TARGETS)

bin/cellular: Makefile bin/board.o bin/cellular_terrain.o src/cellular/main.cpp
	 $(CXX) $(CXXFLAGS) -o bin/cellular bin/board.o bin/cellular_terrain.o src/cellular/main.cpp

bin/board.o: Makefile src/cellular/board.cpp src/cellular/board.hpp
	 $(CXX) $(CXXFLAGS) -c -o bin/board.o src/cellular/board.cpp

bin/cellular_terrain.o: Makefile src/cellular/board.cpp src/cellular/board.hpp
	$(CXX) $(CXXFLAGS) -c -o bin/cellular_terrain.o src/cellular/cellular_terrain.cpp

clean:
	rm -f *.o

distclean: clean
	rm -f $(TARGETS)
