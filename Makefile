PROG=Moduel

VOC=/opt/voc/bin/voc
CC=gcc
VOCPATH=/opt/voc

all: $(PROG)

$(PROG): $(PROG).sym
	$(CC) -fPIC -g -I $(VOCPATH)/C/include \
		-o $(PROG) $(PROG).o \
		$(VOCPATH)/lib/libvoc-OC.a

$(PROG).sym: $(PROG).Mod
	$(VOC) -OC -cesF -m $(PROG).Mod

.PHONY: run clean

run: $(PROG)
	@nl Test.Mod; ./$(PROG)

clean:
	@rm -f *.c *.h *.o *.sym .tmp..* $(PROG)
