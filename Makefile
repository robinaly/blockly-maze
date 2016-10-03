##############################
# Definitions
##############################

USER_APPS = {index,puzzle,maze,bird,turtle,movie,pond/docs,pond/tutor,pond/duck}
ALL_JSON = {./,index,maze}
ALL_TEMPLATES = appengine/template.soy,appengine/index/template.soy,appengine/maze/template.soy

APP_ENGINE_THIRD_PARTY = appengine/third-party
SOY_COMPILER = java -jar third-party/SoyToJsSrcCompiler.jar --shouldProvideRequireSoyNamespaces --isUsingIjData
SOY_EXTRACTOR = java -jar third-party/SoyMsgExtractor.jar

BLOCKY_DIR = $(PWD)

##############################
# Rules
##############################

all: deps languages

index-en:
	mkdir -p appengine/generated/en/
	$(SOY_COMPILER) --outputPathFormat appengine/index/generated/en/soy.js --srcs appengine/index/template.soy
	python build-app.py index en
maze-en: common-en
	$(SOY_COMPILER) --outputPathFormat appengine/maze/generated/en/soy.js --srcs appengine/maze/template.soy
	python build-app.py maze en
common-en:
	$(SOY_COMPILER) --outputPathFormat appengine/generated/en/soy.js --srcs appengine/template.soy

#en: index-en puzzle-en maze-en bird-en turtle-en movie-en pond-docs-en pond-tutor-en pond-duck-en
en: index-en maze-en

languages:
	$(SOY_EXTRACTOR) --outputFile extracted_msgs.xlf --srcs $(ALL_TEMPLATES)
	i18n/xliff_to_json.py --xlf extracted_msgs.xlf --templates $(ALL_TEMPLATES)
	@for app in $(ALL_JSON); do \
	  mkdir -p appengine/$$app/generated; \
	  i18n/json_to_js.py --path_to_jar third-party --output_dir appengine/$$app/generated --template appengine/$$app/template.soy --key_file json/keys.json json/*.json; \
	done
	@for app in $(USER_APPS); do \
	  echo; \
	  echo --- $$app; \
	  for lang in `ls appengine/$$app/generated`; do \
	    python build-app.py $$app $$lang; \
	  done \
	done

deps:
  mkdir -p third-party
  @# All following commands are in third-party, use backslashes to keep them on the same line as the cd command.
  cd third-party; \
  svn checkout https://github.com/google/closure-library/trunk/closure/bin/build build; \
  wget --no-check-certificate -N https://dl.google.com/closure-templates/closure-templates-for-javascript-latest.zip; \
  unzip -o closure-templates-for-javascript-latest.zip SoyToJsSrcCompiler.jar; \
  unzip -o closure-templates-for-javascript-latest.zip -d ../$(APP_ENGINE_THIRD_PARTY) soyutils_usegoog.js; \
  wget --no-check-certificate -N https://dl.google.com/closure-templates/closure-templates-msg-extractor-latest.zip; \
  unzip -o closure-templates-msg-extractor-latest.zip SoyMsgExtractor.jar; \
  wget --no-check-certificate -N https://dl.google.com/closure-compiler/compiler-latest.zip; \
  unzip -o compiler-latest.zip closure-compiler-v20160713.jar
  mv closure-compiler-v20160713.jar compiler.jar
  chmod +x third-party/build/closurebuilder.py

  mkdir -p $(APP_ENGINE_THIRD_PARTY)
  svn checkout https://github.com/google/closure-library/trunk/closure/goog/ $(APP_ENGINE_THIRD_PARTY)/goog
  svn checkout https://github.com/google/closure-library/trunk/third_party/closure/goog/ $(APP_ENGINE_THIRD_PARTY)/third_party_goog
  svn checkout https://github.com/ajaxorg/ace-builds/trunk/src-min-noconflict/ $(APP_ENGINE_THIRD_PARTY)/ace
  svn checkout https://github.com/google/blockly/trunk/ $(APP_ENGINE_THIRD_PARTY)/blockly
  svn checkout https://github.com/mudcube/MIDI.js/trunk/@365 $(APP_ENGINE_THIRD_PARTY)/midi-js
  @# messages.js confuses the compiler by also providing "Blockly.Msg.en".
  rm $(APP_ENGINE_THIRD_PARTY)/blockly/msg/messages.js
  svn checkout https://github.com/NeilFraser/JS-Interpreter/trunk/ $(APP_ENGINE_THIRD_PARTY)/JS-Interpreter
  java -jar third-party/compiler.jar\
   --js appengine/third-party/JS-Interpreter/acorn.js\
   --js appengine/third-party/JS-Interpreter/interpreter.js\
   --js_output_file appengine/third-party/JS-Interpreter/compiled.js

clean: clean-languages clean-deps

clean-languages:
	rm -rf appengine/$(ALL_JSON)/generated
	rm -f json/keys.json

clean-deps:
	rm -rf appengine/third-party
	rm -rf third-party

# Prevent non-traditional rules from exiting with no changes.
.PHONY: deps
