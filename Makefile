# Compilers
CC  ?= gcc
CXX ?= g++

# Lua options
LUAC ?= $(shell pkg-config --cflags lua)
LUAL ?= $(shell pkg-config --libs   lua)

# Linker flags
LDLIBS := $(LUAL)
SHARED := -shared

# Compilation flags
CFLAGS   := $(LUAC) -fPIC -O3 -W -Wall -Wextra -std=c99
CXXFLAGS := $(LUAC) -fPIC -O3 -W -Wall -Wextra -std=c++11

# All targets
TARGETS := \
	components/ca/ca \
	components/ca/ca.so \
	components/sfp/sfp \
	components/voronoi/voronoi \
	h3mapgen.love

# Meta
.PHONY: homm3lua

all: homm3lua $(TARGETS)

# Rules
FILES_CA := $(subst .cpp,.o,$(shell find components/ca -name '*.cpp'))
components/ca/ca: $(FILES_CA)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDLIBS)
components/ca/ca.so: $(FILES_CA)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDLIBS) $(SHARED)

FILES_SFP := $(subst .c,.o,$(shell find components/sfp -name '*.c'))
components/sfp/sfp: $(FILES_SFP)
	$(CXX) -o $@ $^ $(CFLAGS) $(LDLIBS)

FILES_VORONOI := $(subst .cpp,.o,$(shell find components/voronoi -name '*.cpp'))
components/voronoi/voronoi: $(FILES_VORONOI)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDLIBS)

h3mapgen.love: components/gui/*.lua libs/*.lua $(shell find libs/luigi/luigi)
	$(RM) $@
	cp components/gui/conf.lua conf.lua
	cp components/gui/main.lua main.lua
	zip -9 -q -r $@ $(subst components/gui/,,$^) \
		-x "*.git*" \
		-x "*libs/luigi/luigi/backend/ffisdl*" \
		-x "*libs/luigi/luigi/theme/dark*"
	$(RM) conf.lua main.lua

homm3lua:
	$(MAKE) -C libs/homm3lua

# Helpers
clean:
	$(MAKE) -C libs/homm3lua clean
	$(RM) components/*/*.o
	$(RM) -r output

distclean: clean
	$(RM) $(TARGETS)
