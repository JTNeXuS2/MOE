### Установка
Скачать RunAsDate.exe и BattleField_Looper.bat
Поместить в директорию C:\вашкластер\MatrixServerTool
отредактировать BattleField_Looper.bat подставив параметры запуска
из своего StartBattleServer_YYYY.bat копировать от слов (Battlefield_Main_New -game -server ...ваши_аргументы_запуска)
в итоге строка запуска будет выгялеть
RunAsDate.exe /immediate /movetime %day%\%month%\%year% %time% "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" Battlefield_Main_New -game -server ...ваши_аргументы_запуска
также незабудьте указать ид вашего сервера (7020) в строке 
set "serverid=7020"
