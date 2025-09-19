cd /d "%~dp0"
git add .
git commit -m "%date%"
git pull --rebase 
git push github
pause

