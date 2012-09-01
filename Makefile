
DC = dmd
SRCDIR = src/collectd/
SRCDIR = include/
DFLAGS = -Isrc/ -debug -unittest -H -Hdinclude/collectd
modules = collection.d queue.d set.d ringbuffer.d stack.d
FILES = $(addprefix $(SRCDIR), $(modules))

all: release

release:
	$(DC) -lib -ofcollectd -release -O $(DFLAGS) $(FILES) 

debug:
	$(DC) -lib -ofcollectd -debug -unittest $(DFLAGS) $(FILES) 

test: debug
	$(DC)

clean:
	rm collectd.a *.o $(INCDIR)*.di

