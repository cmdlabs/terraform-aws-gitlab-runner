.PHONY: docs check unit
.DEFAULT_GOAL := all
docs:
	ruby erb/docs.rb

check:
	shellcheck --exclude=SC2154,SC2155 template/user-data.sh.tpl

unit:
	bash shunit2/validate_json.sh ; \
		bash shunit2/test_user_data.sh

all: check unit
