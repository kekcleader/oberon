PROG=Compiler

VOC=/opt/voc/bin/voc
CC=gcc
VOCPATH=/opt/voc
VOCLIBS=$(VOCPATH)/lib/libvoc-OC.a
COMPILE=$(VOC) -OC -cesF

all: $(PROG)

$(PROG): $(PROG).sym
	$(CC) -fPIC -g -I $(VOCPATH)/C/include \
		-o $(PROG) Parser.o Scanner.o \
		SymTable.o Generator.o \
		Chmod.o \
		c_chmod.o \
		$(PROG).o \
    $(VOCLIBS)

$(PROG).sym: Mod/$(PROG).Mod Parser.sym
	$(COMPILE) -m Mod/$(PROG).Mod

Parser.sym: Mod/Parser.Mod Scanner.sym SymTable.sym Generator.sym
	$(COMPILE) Mod/Parser.Mod

Scanner.sym: Mod/Scanner.Mod
	$(COMPILE) Mod/Scanner.Mod

Generator.sym: Mod/Generator.Mod SymTable.sym Chmod.sym
	$(COMPILE) Mod/Generator.Mod

SymTable.sym: Mod/SymTable.Mod
	$(COMPILE) Mod/SymTable.Mod

Chmod.sym: Mod/Chmod.Mod c_chmod.o
	$(VOC) -OC -fF Mod/Chmod.Mod

c_chmod.o: Mod/c_chmod/c_chmod.c Mod/c_chmod/c_chmod.h
	$(CC) -c Mod/c_chmod/c_chmod.c -o c_chmod.o
	cp Mod/c_chmod/c_chmod.h .

.PHONY: run clean

run: $(PROG)
	@clear; nl Test.Mod; ./$(PROG)

clean:
	@rm -f *.c *.h *.o *.sym .tmp..* Test $(PROG)
