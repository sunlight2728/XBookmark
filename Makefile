xcodebuild:=xcodebuild -configuration

ifdef BUILDLOG
REDIRECT=>> $(BUILDLOG)
endif

.PHONY: release debug clean clean-release clean-debug uninstall uuid build-test

release: uuid
	$(xcodebuild) Release $(REDIRECT)

debug: uuid
	$(xcodebuild) Debug $(REDIRECT)


clean: clean-release clean-debug

clean-release:
	$(xcodebuild) Release clean

clean-debug:
	$(xcodebuild) Debug clean


uninstall:
	rm -rf "$(HOME)/Library/Application Support/Developer/Shared/Xcode/Plug-ins/XBookmark.xcplugin"

uuid:
	@xcode_path=`xcode-select -p`; \
	uuid=`defaults read "$${xcode_path}/../Info" DVTPlugInCompatibilityUUID`; \
	xcode_version=`defaults read "$${xcode_path}/../Info" CFBundleShortVersionString`; \
	grep $${uuid} XBookmark/Info.plist > /dev/null ; \
	if [ $$? -ne 0 ]; then \
		printf "XBookmark hasn't confirmed the compatibility with your Xcode, Version $${xcode_version}\n"; \
		printf "Do you want to compile XBookmark with support Xcode Version $${xcode_version} at your own risk? (y/N)"; \
		read -r -n 1 in; \
		if [[ $$in != "" &&  ( $$in == "y" || $$in == "Y") ]]; then \
			plutil -insert DVTPlugInCompatibilityUUIDs.0 -string $${uuid} XBookmark/Info.plist; \
		fi ;\
		printf "\n"; \
	fi ;

# Build with all the available Xcode in /Applications directory
build-test:
	@> build.log; \
    xcode_path=`xcode-select -p`; \
	for xcode in /Applications/Xcode*.app; do \
		sudo xcode-select -s "$$xcode"; \
		echo Building with $$xcode >> build.log; \
		"$(MAKE)" -C . BUILDLOG=build.log; \
	done; \
	sudo xcode-select -s $${xcode_path}; \
