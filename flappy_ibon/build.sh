#!/bin/bash

cmd="/mnt/c/Windows/System32/cmd.exe"
path_love="C:\Program Files\LOVE"
path_game="A:\home\flamendless\flappy_ibon\flappy_ibon.love"

function run()
{
	echo "Running build_win.sh"
	zip -9ru flappy_ibon.love assets build.sh conf.lua main.lua -x flappy_ibon.love
	$cmd /c "cd $path_love & lovec.exe $path_game"
	echo "Completed build_win.sh"
}

"$@"
