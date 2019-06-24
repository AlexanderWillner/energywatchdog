run:
	@bash ws.willner.energywatchdog.sh

install:
	@cp ws.willner.energywatchdog.sh /usr/local/bin
	@cp ws.willner.energywatchdog.plist $$HOME/Library/LaunchAgents/

remove:
	@rm /usr/local/bin/ws.willner.energywatchdog.sh || exit 0
	@rm $$HOME/Library/LaunchAgents/ws.willner.energywatchdog.plist || exit 0