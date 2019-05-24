AS=asl
P2BIN=p2bin
SRC=patch.s
BSPLIT=bsplit
MAME=mame
ROMDIR=/home/moffitt/.mame/roms

ASFLAGS=-i . -n -U -g

.PHONY: game_prg

all: game_prg

game_prg:
	$(AS) $(SRC) $(ASFLAGS) -o prg.o
	$(P2BIN) prg.o prg.bin -r \$$-0x7FFFF
	$(BSPLIT) s prg.bin cpu.even cpu.odd
	split -b 131072 cpu.even
	mv xaa c07_20-2.74
	mv xab c07_21-2.76
	split -b 131072 cpu.odd
	mv xaa c07_19-2.73
	mv xab c07_18-2.71
	rm cpu.odd
	rm cpu.even

test: game_prg
	$(MAME) -debug darius2d

clean:
	@-rm prg.bin
	@-rm prg.o
