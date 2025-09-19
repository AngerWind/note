
REM 切换到当前脚本所在目录
cd /d "%~dp0"

REM 添加改动
git add .

REM 提交，提交信息是当前日期
git commit -m "%date%"

REM 拉取远程分支并 rebase
git pull --rebase

REM 推送到 github 远程
git push github

pause
