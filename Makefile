TARGET = micro_vp.exe

SRCS = 	micro.vp \
		sera.vp \
		fs.vp \
		ttf.vp \
		m_event.vp \
		m_window.vp \
		m_timer.vp \
		m_gfx.vp \
		m_data.vp \
		m_image.vp \
		m_imagefx.vp \
		m_font.vp \
		m_fs.vp \
		m_mouse.vp \
		m_system.vp \
		m_source.vp \
		m_audio.vp \
		teax.vp \
       	spxe.vp \
        gleq.vp \
        stb_image.vp \
        stb_truetype.vp

OBJS = $(SRCS:.vp=.obj)
C_OBJS = miniz.obj miniaudio.obj

# Use an environment variable...
#VXC_STD ?=
VXC_OBJS = $(VXC_STD)/math.obj $(VXC_STD)/mem.obj $(VXC_STD)/str.obj $(VXC_STD)/io.obj $(VXC_STD)/os.obj $(VXC_STD)/conv.obj

CC ?= clang
CFLAGS ?= -O2
MINIZ_CFLAGS = $(CFLAGS)
#-DMINIZ_NO_STDIO
CLANG_RT_LIBDIR = $(shell clang --print-resource-dir)/lib/windows

LDFLAGS = -L. --entry=main --subsystem=console
LIBS = -ltea00 -lglfw3 -lkernel32 -lopengl32 -lgdi32 -luser32 -lucrt -L$(CLANG_RT_LIBDIR) -lclang_rt.builtins-x86_64

EMBED_TEA_FILES = $(wildcard embed/*.tea)
EMBED_FONT_FILES = $(wildcard embed/*.ttf)
EMBED_VP_HEADERS = $(patsubst embed/%.tea, embed/%_tea.vp, $(EMBED_TEA_FILES))
EMBED_VP_HEADERS += $(patsubst embed/%.ttf, embed/%_ttf.vp, $(EMBED_FONT_FILES))

# Rules
.PHONY: all embed clean

all: $(TARGET)

embed: $(EMBED_VP_HEADERS)

embed/%_tea.vp: embed/%.tea
	@echo "  EMBED                     $@"
	@python embed.py $< > $@

embed/%_ttf.vp: embed/%.ttf
	@echo "  EMBED                     $@"
	@python embed.py $< > $@

$(VXC_OBJS):
	$(if $(wildcard $@),,$(error Pre-built object $@ is missing))

$(TARGET): $(OBJS) $(C_OBJS) $(VXC_OBJS)
	@echo "  LINK                      $@"
	@ld $(OBJS) $(C_OBJS) $(VXC_OBJS) $(LDFLAGS) $(LIBS) -o $@
	@echo "  OK"

%.obj: %.vp
	@echo "  VXC                       $@"
	@vxc comp $<

# micro.vp #includes the generated embed headers, so it must re-compile
# whenever any of them are regenerated (which itself is triggered by
# changes to the underlying .tea / .ttf source files).
micro.obj: micro.vp $(EMBED_VP_HEADERS)
	@echo "  VXC                       $@"
	@vxc comp micro.vp

miniz.obj: miniz.c miniz.h
	@echo "  CC                        $@"
	@$(CC) $(MINIZ_CFLAGS) -c miniz.c -o $@

miniaudio.obj: miniaudio.c
	@echo "  CC                        $@"
	@$(CC) $(CFLAGS) -DMINIAUDIO_IMPLEMENTATION -c miniaudio.c -o $@

clean:
	@rm -f $(OBJS) $(C_OBJS) $(TARGET)
	@echo "  CLEAN"
