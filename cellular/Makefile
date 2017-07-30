CXX ?= g++
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef

# Auto-dependency generation method from:
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

COMPILE = $(CXX) -c $(DEPFLAGS) $(CXXFLAGS) $(CPPFLAGS) -o $@
LINKER = $(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $@
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

TARGETS = cellular
SRCS = $(wildcard *.cpp)
OBJS = $(SRCS:.cpp=.o)

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	rm -f *.o
	rm -rf .d

.PHONY: distclean
distclean: clean
	rm -f $(TARGETS)

cellular: Makefile $(OBJS)
	$(LINKER) $(OBJS) 

$(OBJS): %.o: %.cpp $(DEPDIR)/%.d
	$(COMPILE) $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(SRCS))))
