

cd /d "%~dp0"


git add .


git commit -m "%date%"


git pull github --rebase


git push github

pause
