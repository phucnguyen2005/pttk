@echo off
chcp 65001 >nul
set CATALINA_HOME=D:\tomcat9
set APP=%CATALINA_HOME%\webapps\garage
cd /d "%~dp0"

echo Dang chep JSP va bien dich model...
xcopy /E /I /Y /Q src\main\webapp "%APP%" >nul
if not exist "%APP%\WEB-INF\classes" mkdir "%APP%\WEB-INF\classes"
if not exist "%APP%\WEB-INF\lib" mkdir "%APP%\WEB-INF\lib"
if exist lib\*.jar copy /Y lib\*.jar "%APP%\WEB-INF\lib" >nul
if not exist "%APP%\WEB-INF\lib\mysql-connector-j*.jar" (echo Thieu mysql-connector-j jar: dat vao thu muc lib\ roi chay lai & pause & exit /b 1)
dir /b /s src\main\java\*.java > "%TEMP%\garage_src.txt"
javac -encoding UTF-8 --release 11 -d "%APP%\WEB-INF\classes" @"%TEMP%\garage_src.txt"
if errorlevel 1 (echo Loi bien dich & pause & exit /b 1)

if not defined JAVA_HOME (
  for /f "delims=" %%i in ('where javac') do set "JAVAC=%%i"
  for %%i in ("%JAVAC%") do set "JAVA_HOME=%%~dpi.."
)
call "%CATALINA_HOME%\bin\shutdown.bat" >nul 2>&1
timeout /t 3 >nul
call "%CATALINA_HOME%\bin\startup.bat"

echo.
echo Cho vai giay roi mo: http://localhost:8080/garage/
echo Khach hang: customer1 / 123456   Nhan vien ban hang: sales1 / 123456
timeout /t 10 >nul
start http://localhost:8080/garage/
