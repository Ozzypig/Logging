VERSION = 0.2.0

ROJO = rojo

ROJO_PROJECT = default.project.json
ROJO_PROJECT_TEST = test.project.json

OUT = Logging-v$(VERSION).rbxmx
OUT_TEST = Logging.rbxlx

SRC = Logging
SRC_VERSION = $(SRC)/Version.lua

.PHONY = test serve clean clean-build clean-test clean-src-version

# Main build

$(OUT) : $(ROJO_PROJECT) $(SRC)
	echo "return \"$(VERSION)\"" > $(SRC_VERSION)
	$(ROJO) build $(ROJO_PROJECT) --output $(OUT)

$(SRC) : $(shell find $(SRC) -type f)

# Test

SRC_TEST = test

test : $(OUT_TEST)

$(OUT_TEST) : $(ROJO_PROJECT_TEST) $(SRC_TEST)
	$(ROJO) build $(ROJO_PROJECT_TEST) --output $(OUT_TEST)

$(SRC_TEST) : $(shell find $(SRC) -type f)

serve : test
	$(ROJO) serve $(ROJO_PROJECT_TEST)

# Clean

clean : clean-build clean-test clean-src-version

clean-build :
	$(RM) $(OUT)

clean-test :
	$(RM) $(OUT_TEST)

clean-src-version :
	$(RM) $(SRC_VERSION)
