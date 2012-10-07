
DC = dmd
SRCDIR = src/collectd/
INCDIR = include
DFLAGS = -Isrc/ -debug -unittest -H -Hd$(INCDIR)/collectd
modules = collection.d queue.d set.d ringbuffer.d stack.d list.d
FILES = $(addprefix $(SRCDIR), $(modules))

all: release

include:
	mkdir -p $(OBJDIR)


release:
	$(DC) -lib -ofcollectd -release -O $(DFLAGS) $(FILES) 

debug:
	$(DC) -lib -ofcollectd -debug -unittest $(DFLAGS) $(FILES) 

test: debug
	$(DC)

clean:
	rm collectd.a *.o $(INCDIR)/*.di

