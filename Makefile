OBJDIR=Work
VERSION=2.0.0
WORK=wb_counter
PKG=$(WORK)-$(VERSION)
GHDL=ghdl
GHDL_FLAGS=-P../utils/Work/ -P../wb_handler/Work/ --work=$(WORK) --workdir=$(OBJDIR)
GTKWAVE=gtkwave
TBEXE=$(OBJDIR)/testbench
VCD=$(OBJDIR)/wb_counter_tb.vcd

vpath %.o $(OBJDIR)

all: $(TBEXE) $(OBJDIR)/wb_counter.h

%.o: %.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<
	#bakalint.pl -i $< -r $(OBJDIR)/replace.txt #-d $(OBJDIR)/$@

%.o: $(OBJDIR)/%.vhdl
	$(GHDL) -a $(GHDL_FLAGS) $<

$(OBJDIR):
	mkdir $(OBJDIR)

$(OBJDIR)/wb_counter.h: $(OBJDIR)/wb_counter_pkg.vhdl
	xtracth.pl $<

clean:
	-rm -r $(OBJDIR)

wb_counter_tb.o: wb_counter.o
wb_counter.o: wb_counter_pkg.o

$(OBJDIR)/wb_counter_pkg.vhdl: wb_counter_pkg.in.vhdl wb_counter.vhdl
	vhdlspp.pl $< $@

$(TBEXE): $(OBJDIR) wb_counter_tb.o
	$(GHDL) -e $(GHDL_FLAGS) -o $(TBEXE) testbench

test: $(TBEXE)
	$< --stop-time=100us --wave=$(TBEXE).ghw
#	-$(TBEXE) --vcd=$(VCD)
#	$(GTKWAVE) $(VCD) &

tarball: wb_counter.h
	cd .. ; perl gentarball.pl wb_counter $(WORK) $(VERSION)

