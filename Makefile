.PHONY: docs check unit
.DEFAULT_GOAL := all
docs:
	ruby erb/docs.rb

check:
	shellcheck --exclude=SC2154 template/user-data.sh.tpl

unit:
	bash shunit2/validate_json.sh

all: check unit
