@echo off
set EXPRESS_PORT=8181
set HUBOT_BRAIN_USE_STORAGE_EMULATOR=true
set HUBOT_LOG_LEVEL=debug
npm install && node_modules\.bin\hubot.cmd --name "hubot" %* 