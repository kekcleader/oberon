PROG=Compiler

VOC=/opt/voc/bin/voc
CC=gcc
VOCPATH=/opt/voc
COMPILE=$(VOC) -OC -cesF

all: $(PROG)

$(PROG): $(PROG).sym
	$(CC) -fPIC -g -I $(VOCPATH)/C/include \
		-o $(PROG) Parser.o Scanner.o $(PROG).o \
		$(VOCPATH)/lib/libvoc-OC.a

$(PROG).sym: $(PROG).Mod Parser.sym
	$(COMPILE) -m $(PROG).Mod

Parser.sym: Parser.Mod Scanner.sym
	$(COMPILE) Parser.Mod

Scanner.sym: Scanner.Mod
	$(COMPILE) Scanner.Mod

.PHONY: run clean

run: $(PROG)
	@nl Test.Mod; ./$(PROG)

clean:
	@rm -f *.c *.h *.o *.sym .tmp..* $(PROG)
