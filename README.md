IMPORTANT!!! / ВАЖНО!!!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/White-blue-white_flag.svg/1280px-White-blue-white_flag.svg.png?utm_source=ru.wikipedia.org&utm_campaign=imageinfo&utm_content=thumbnail" width="30" height="20" alt="Россия"> Россия будет свободной! / Russia will be free!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Flag_of_Belarus_%281918%2C_1991%E2%80%931995%29.svg/1920px-Flag_of_Belarus_%281918%2C_1991%E2%80%931995%29.svg.png?utm_source=ru.wikipedia.org&utm_campaign=imageinfo&utm_content=thumbnail" width="30" height="20" alt="Беларусь"> Жыве Беларусь! / Long Live Belarus!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Flag_of_Ukraine.svg/1280px-Flag_of_Ukraine.svg.png?utm_source=ru.wikipedia.org&utm_campaign=imageinfo&utm_content=thumbnail" width="30" height="20" alt="Украина"> Слава Украине! / Glory to Ukraine!

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Flag_of_Palestine.svg/1920px-Flag_of_Palestine.svg.png?utm_source=ru.wikipedia.org&utm_campaign=imageinfo&utm_content=thumbnai" width="30" height="20" alt="Палестина"> Free Palestine! / Свободу Палестине!


Блокировщик российских сервисов для всех устройств

Что заблокированно?

- Яндекс (все сервисы)
- ВК (все сервисы)
- Мессенджер МАКС
- Рувики
- Рутуб
- 2гис

Как установить?

Windows

1.  Настройки - Сеть и Интернет - Wi-Fi - Свойства оборудования
2.  Во вкладке назначение dns-сервера нажать изменить
3.  Изменить настройки так как на скриншоте:
<img width="640" height="956" alt="image" src="https://github.com/user-attachments/assets/08381d2b-c760-4614-b380-0eb97d44188f" />

Браузеры

Chrome

1. Перейти в настройки безопасности chrome://settings/security
2. Изменить настройки так как на скриншоте:
<img width="974" height="265" alt="image" src="https://github.com/user-attachments/assets/88ae8e16-a71a-40a7-b95c-222088cf6172" />

Firefox

1. Перейти в настройки doh about:preferences#dnsOverHttps
2. Изменить настройки так как на скриншоте:
<img width="1306" height="706" alt="image" src="https://github.com/user-attachments/assets/fd7e3ee4-68c9-48b8-a509-d39575d2942e" />

Android

1. Зайти в настройки dns
2. Изменить dns на russianservicesblacklist.duckdns.org

macOS/iOS

1. [Скачайте файл](https://github.com/mrtag-oss/russianservicesblacklist/blob/main/rsb.mobileconfig) .mobileconfig через браузер Safari на вашем устройстве. 
2. Подтвердите загрузку профиля в появившемся окне.
3. Перейдите в Настройки (Settings) на iOS или Системные настройки на macOS.
4. Откройте раздел Профиль загружен (Profile Downloaded) или перейдите в Основные -> Профили и управление устройством.
5. Выберите скачанный профиль и нажмите Установить (Install), следуя инструкциям на экране.

Linux

1. Открыть терминал
2. Открыть конфиг командой sudo nano /etc/systemd/resolved.conf
3. В секции [Resolve] раскомментировать параметры DNS и DOT
4. Привести их к такому виду:
<img width="644" height="445" alt="image" src="https://github.com/user-attachments/assets/402570c2-5a4e-4511-a9fc-31b12a879337" />

5. Сохранить конфиг и выйти из редактора 
6. Запустить командой:

sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

sudo systemctl restart systemd-resolved
7. Проверка:

Ввести по отдельности комманды resolvectl status и nslookup ya.ru

Должно быть примено так:

<img width="697" height="450" alt="image" src="https://github.com/user-attachments/assets/f0d317d4-f001-41ca-95de-b8eb37d23f18" />

Откат:
1. Закомментировать строки dns и dot в конфиге (конфиг открывается командой sudo nano /etc/systemd/resolved.conf)
2. Сохранить файл, выйти из редактора 
3. Перезагрузить службу командой sudo systemctl restart systemd-resolved
