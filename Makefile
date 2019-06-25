plist=ws.willner.energywatchdog.plist
script=ws.willner.energywatchdog.sh
target_bin=/usr/local/bin
target_agent=$$HOME/Library/LaunchAgents/

help:
	@echo "Nothing really to make, but there are some available commands:"
	@echo " * run      : run application to test it"
	@echo " * install  : install application as an agent"
	@echo " * remove   : remove agent"
	@echo " * feedback : create a GitHub issue"
	@echo " * style    : style bash scripts"
	@echo " * harden   : harden bash scripts"

run:
	@bash "$(script)"

debug:
	@DEBUG_SLEEP=1 DEBUG_MAX=1 DEBUG_BATTERY=0 bash "$(script)"

install: remove
	@cp "$(script)" "$(target_bin)"
	@cp "$(plist)" "$(target_agent)/$(plist)"
	@launchctl load -w "$(target_agent)/$(plist)"

remove:
	@launchctl unload -w "$(target_agent)/$(plist)" 2>/dev/null || exit 0
	@rm "$(target_bin)/$(script)" 2>/dev/null || exit 0
	@rm "$(target_agent)/$(plist)" 2>/dev/null || exit 0

feedback:
	@open https://github.com/AlexanderWillner/energywatchdog

harden:
	@type shellharden >/dev/null 2>&1 || (echo "Run 'brew install shellharden' first." >&2 ; exit 1)
	@shellharden --replace "$(script)"
	
style:
	@type shfmt >/dev/null 2>&1 || (echo "Run 'brew install shfmt' first." >&2 ; exit 1)
	@shfmt -i 2 -w -s "$(script)"
