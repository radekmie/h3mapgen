CXX = g++
CXXFLAGS = -Wall -O2 $(shell pkg-config --cflags lua5.3) 
LDLIBS = $(shell pkg-config --libs lua5.3)
RM = rm -v -f

all: terrain.so

terrain.so: lua_wrapper.cpp		
	$(CXX) $(CXXFLAGS) $^ $(LDLIBS) -shared -o terrain.so
clean:
	@$(RM) terrain.so
	@$(RM) *~
