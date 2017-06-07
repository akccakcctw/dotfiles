;= @echo off
;= :: Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= :: In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here

;= :: Shortcuts
e.=explorer .
rm=rm -i $*
mv=mv -i $*
gst=git status
gs=git show
gl=git log --oneline --all --graph --decorate  $*
ll=ls -l --color $*
ls=ls --show-control-chars -F --color $*
pwd=cd
clear=cls
history=cat %CMDER_ROOT%\config\.history
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"
myip=nslookup myip.opendns.com. resolver1.opendns.com

;= :: Edit host file
eHost=vim %SystemRoot%\system32\drivers\etc\hosts

;= :: Easier navigation
..=cd ..
...=cd ../..
....=cd ../../..
.....=cd ../../../..

;= :: for Bash on Ubuntu on Windows
bash=%windir%\system32\bash.exe -cur_console:p

;= :: ssh
sshVMbox=ssh -t root@192.168.42.220 "cd /var/www/html/ ; bash"
