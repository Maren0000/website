@echo off
set key=6d6b3a39747a785752467d4a707a7732
set iv=4e46586a6571286e3a33672738263d3b
if not exist encrypted mkdir encrypted
for %%i in (%*) do (
    openssl aes-128-cbc -in %%i -out encrypted\%%~nxi -K %key% -iv %iv%
    if errorlevel 1 (
        echo Encryption failed for file %%i.
        exit /b 1
    ) else (
        echo Encryption successful for file %%i.
    )
)
pause
