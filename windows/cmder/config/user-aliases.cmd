;= @echo off
;= :: Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= :: In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here

;= :: Aliases
e.=explorer .
rm=rm -i $*
mv=mv -i $*
ls=ls --show-control-chars -F --group-directories-first --color $*
ll=ls -l --group-directories-first --color $*
pwd=cd
clear=cls
history=cat %CMDER_ROOT%\config\.history
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"
myip=nslookup myip.opendns.com. resolver1.opendns.com

;= :: Git
g=git $*
gst=git status
gs=git show
gl=git log --oneline --all --graph --decorate  $*
gll=git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short $*

;= :: Edit host file
eHost=vim %SystemRoot%\system32\drivers\etc\hosts

;= :: Easier navigation
~=cd %HOMEPATH%
..=cd ..
...=cd ../..
....=cd ../../..
.....=cd ../../../..

;= :: for WSL (Windows Subsystem for Linux)
bash=%windir%\system32\bash.exe -cur_console:p

;= :: ssh
sshVMbox=ssh -t root@192.168.42.220 "cd /var/www/html/ ; bash"
sshPTT=ssh bbsu@ptt.cc
