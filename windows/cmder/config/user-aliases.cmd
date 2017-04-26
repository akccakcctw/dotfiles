;= @echo off
;= rem Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= rem In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here
e.=explorer .
eHost=vim %SystemRoot%\system32\drivers\etc\hosts
rm=rm -i $*
mv=mv -i $*
gs=git status
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

;= rem for Bash on Ubuntu on Windows
bash=%windir%\system32\bash.exe -cur_console:p

;= rem ssh
sshVMbox=ssh -t root@192.168.42.220 "cd /var/www/html/ ; bash"
