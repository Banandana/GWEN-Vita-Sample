PHONY := all package clean
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

CC := arm-vita-eabi-gcc
CXX := arm-vita-eabi-g++
STRIP := arm-vita-eabi-strip


PROJECT_TITLE := Gwen Sample
PROJECT_TITLEID := VHB000001

PROJECT := gwen_sample
CXXFLAGS += -std=c++11 -g

LIBS := -lGWEN -lvita2d -lSceKernel_stub -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lSceAppUtil_stub -lSceCtrl_stub -lScePgf_stub \
	-lSceCommonDialog_stub -lfreetype -lpng -ljpeg -lz -lm -lc


SRC_C :=$(call rwildcard, src/, *.c)
SRC_CPP :=$(call rwildcard, src/, *.cpp)

OBJ_DIRS := $(addprefix out/, $(dir $(SRC_C:src/%.c=%.o))) $(addprefix out/, $(dir $(SRC_CPP:src/%.cpp=%.o)))
OBJS := $(addprefix out/, $(SRC_C:src/%.c=%.o)) $(addprefix out/, $(SRC_CPP:src/%.cpp=%.o))

all: package

package: $(PROJECT).vpk

$(PROJECT).vpk: eboot.bin param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin \
		--add sce_sys/icon0.png=sce_sys/icon0.png \
		--add sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
		--add res/DefaultSkin.png=res/DefaultSkin.png \
		--add res/bg.png=res/bg.png \
		--add res/Roboto-Regular.ttf=res/Roboto-Regular.ttf \
	$(PROJECT).vpk

eboot.bin: $(PROJECT).velf
	vita-make-fself $(PROJECT).velf eboot.bin

param.sfo:
	vita-mksfoex -s TITLE_ID="$(PROJECT_TITLEID)" "$(PROJECT_TITLE)" param.sfo

$(PROJECT).velf: $(PROJECT).elf
	$(STRIP) -g $<
	vita-elf-create $< $@

$(PROJECT).elf: $(OBJS)
	$(CXX) -Wl,-q -g -Og -o $@ $^ $(LIBS)

$(OBJ_DIRS):
	mkdir -p $@

out/%.o : src/%.cpp | $(OBJ_DIRS)
	arm-vita-eabi-g++ -Og -g -c $(CXXFLAGS) -o $@ $<

out/%.o : src/%.c | $(OBJ_DIRS)
	arm-vita-eabi-g++ -g -Og -c -o $@ $<

clean:
	rm -f $(PROJECT).velf $(PROJECT).elf $(PROJECT).vpk param.sfo eboot.bin $(OBJS)
	rm -r $(abspath $(OBJ_DIRS))

vpksend: $(PROJECT).vpk
	curl -T $(PROJECT).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(PROJECT_TITLEID)/
	@echo "Sent."
# DO NOT DELETE
