TARGET = micro_vp.exe

SRCS = 	micro.vp \
		sera.vp \
		fs.vp \
		ttf.vp \
		event.vp \
		window.vp \
		timer.vp \
		gfx.vp \
		data.vp \
		image.vp \
		font.vp \
       	spxe.vp \
        gleq.vp \
        stb_image.vp \
        stb_truetype.vp

OBJS = $(SRCS:.vp=.obj)

# Use an environment variable...
VXC_STD ?= .
VXC_OBJS = $(VXC_STD)/math.obj $(VXC_STD)/mem.obj $(VXC_STD)/str.obj $(VXC_STD)/io.obj $(VXC_STD)/os.obj $(VXC_STD)/conv.obj

LDFLAGS = -L. --entry=main --subsystem=console
LIBS = -ltea00 -lglfw3 -lkernel32 -lopengl32 -lgdi32 -luser32

# Rules
.PHONY: all clean

all: $(TARGET)

$(VXC_OBJS):
	$(if $(wildcard $@),,$(error Pre-built object $@ is missing))

$(TARGET): $(OBJS) $(VXC_OBJS)
	@echo "  LINK                      $@"
	@ld $(OBJS) $(VXC_OBJS) $(LDFLAGS) $(LIBS) -o $@
	@echo "  OK"

%.obj: %.vp
	@echo "  VXC                       $@"
	@vxc comp $<

clean:
	@rm -f $(OBJS) $(TARGET)
	@echo "  CLEAN"