# macOS Energy Watchdog

## Summary

Simple macOS watchdog script that kills processes that consume a lot of energy.

## Description

When working mobile your MacBook should run as long as possible. However, sometimes tasks in the background drain the battery significantly. Often this is only recognized when a low energy warning pops up. This simple script runs in the background as an agent and kills selected processes, in case they are consuming too much of the CPU (e.g. ```> 80%```) within a small time frame (e.g. ```1 minute```).

## Usage

You should modify the header of the file ```ws.willner.energywatchdog.sh``` as needed before installing the daemon. The ```make``` commands:

```
$ make run # to run
$ make install # to install to /usr/local/bin and ~/Library/LaunchAgents
$ make remove # to remove
```

## Screenshot

Normally you're not seeing this script. However, here is the output when running manually. Here ```Messages.app``` gets killed.

![Screenshot](img/screenshot.png "Screenshot")
