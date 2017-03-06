XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME) -destination $(DESTINATION)

SCHEME ?= $(TARGET)-$(PLATFORM)
PLATFORM ?= iOS
OS ?= 9.1
RELEASE ?= beta
BRANCH ?= master
DIST_BRANCH = $(RELEASE)-dist

bootstrap: dependencies secrets

dependencies:
	@carthage update --use-submodules --no-use-binaries --platform iOS

submodules:
	@git submodule sync --recursive || true
	@git submodule update --init --recursive || true

secrets:
	@if [ ! -e GroveGardenController/Secrets.swift ]; \
	then \
		cp Configs/Secrets.swift.example GroveGardenController/Secrets.swift \
		&& cp Configs/Secrets.swift GroveGardenController/Secrets.swift 2>/dev/null || echo 'No custom Config/Secrets.swift file found.' \
		|| true; \
	fi
