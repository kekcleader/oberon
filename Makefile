PROG=Compiler

VOC=/opt/voc/bin/voc
CC=gcc
VOCPATH=/opt/voc
COMPILE=$(VOC) -OC -cesF

all: $(PROG)

$(PROG): $(PROG).sym
	$(CC) -fPIC -g -I $(VOCPATH)/C/include \
		-o $(PROG) Parser.o Scanner.o \
		SymTable.o Generator.o \
		Chmod.o \
		chmod/chmod.o \
		$(PROG).o \
		$(VOCPATH)/lib/libvoc-OC.a

$(PROG).sym: $(PROG).Mod Parser.sym
	$(COMPILE) -m $(PROG).Mod

Parser.sym: Parser.Mod Scanner.sym SymTable.sym Generator.sym
	$(COMPILE) Parser.Mod

Scanner.sym: Scanner.Mod
	$(COMPILE) Scanner.Mod

Generator.sym: Generator.Mod SymTable.sym Chmod.sym
	$(COMPILE) Generator.Mod

SymTable.sym: SymTable.Mod
	$(COMPILE) SymTable.Mod

Chmod.sym: Chmod.Mod chmod/chmod.o
	$(VOC) -OC -fF Chmod.Mod

chmod/chmod.o: chmod/chmod.c chmod/chmod.h
	$(CC) -c chmod/chmod.c -o chmod/chmod.o

.PHONY: run clean

run: $(PROG)
	@clear; nl Test.Mod; ./$(PROG)

clean:
	@rm -f *.c *.h *.o *.sym .tmp..* chmod/*.o $(PROG)
