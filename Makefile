HSC=ghc
HSFLAGS=-Wall
SOURCES:=$(wildcard ./src/*.hs)
TESTIN:=$(wildcard ./test/*.in)
TESTOUT:=$(TESTIN:./%.in=./%.out)
TESTOK:=$(TESTIN:./%.in=./%.ok)

EXE=flp21-fun
ZIP=flp21-fun-xwagne10.zip

.PHONY: all clean pack zip tar run test

############################################
# PROGRAM
all: $(EXE)
$(EXE): $(SOURCES)
	$(HSC) $(HSFLAGS) $^ -o $@


############################################
# DOCUMENTATION
test: $(EXE) $(TESTIN) $(TESTOUT) $(TESTOK)
	echo "All tests ran without problems"

test/%.ok: test/%.in test/%.out
	./$(EXE) -2 $< | diff $(word 2,$^) -


############################################
# MISC

tar: pack
zip: pack
pack: 
	rm -f $(ZIP)
	zip -r $(ZIP) doc src test Makefile	

clean:
	rm -f $(ZIP) $(EXE) ./src/*.hi ./src/*.o

run: $(EXE)
	./$(EXE) -i -1 -2