# OneScript Version Manager

[![Release](https://img.shields.io/github/release/oscript-library/ovm/all.svg)](https://github.com/oscript-library/ovm/releases)
[![Build Status](https://travis-ci.org/oscript-library/ovm.svg?branch=develop)](https://travis-ci.org/oscript-library/ovm)
[![Quality Gate](https://sonar.openbsl.ru/api/project_badges/measure?project=ovm&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=ovm)
[![Tech Debt](https://sonar.openbsl.ru/api/project_badges/measure?project=ovm&metric=sqale_index)](https://sonar.openbsl.ru/dashboard?id=ovm)

## Цель

ovm - утилита, предназначенная для установки, обновления и переключения между различными версиями OneScript. Вдохновение черпается из nvm (node.js version manager)

## Пререквизиты

* Установленный `.Net Framework >=4.5.2` либо `Mono >=4.6`
* Работающий интернет

## Установка

Для упрощения миграции на ovm перед установкой рекомендуется удалить системный OneScript и выполнить выход из системы/вход в систему. 

### Windows

* Скачать `ovm.exe` со страницы [страницы релизов GitHub](https://github.com/oscript-library/ovm/releases)
* По желанию прописать путь к ovm.exe в переменной окружения `PATH`

### Linux

* Скачать `ovm.exe` со страницы [страницы релизов GitHub](https://github.com/oscript-library/ovm/releases)
* Для быстрого использования приложения можно создать sh-файл со следующим содержанием:

```sh
mono path/to/ovm.exe "$@"
```

и добавить его в `$PATH` (например, в `~/.local/share/bin`)

## Поддержка различных терминалов

Для каждого из терминалов активация ovm выглядит по-разному. После выполнения первичной активации в большинстве случаев необходимо переоткрыть текущий терминал (это надо сделать один раз). Для перечисленных ниже терминалов действия по активации происходят **автоматически**.

<a id="use_cmd"></a>

### cmd (Windows)

При первичной активации версии OneScript при наличии системной установки OneScript:

создается запись в реестре по адресу `HKCU\Software\Microsoft\Command Processor\Autorun` следующего содержания:

```cmd
set PATH=%OVM_OSCRIPTBIN%;%PATH%
```

### powershell (Windows)

При первичной активации версии OneScript при наличии системной установки OneScript:

создается файл (либо добавляется в существующий) по адресу `%USERPROFILE%\Documents\WindowsPowerShell\profile.ps1` со следующим содержанием:

```powershell
set PATH=$OVM_OSCRIPTBIN;$PATH
```

### sh (*nix)

При первичной активации версии OneScript:

создается файл (либо добавляется в существующий) по адресу `$HOME/.profile` со следующим содержанием:

```sh
export $HOME/.local/share/ovm/current/bin:$PATH
```

### bash (*nix)

При первичной активации версии OneScript:

создается файл (либо добавляется в существующий) по адресу `$HOME/.bashrc` со следующим содержанием:

```bash
export $HOME/.local/share/ovm/current/bin:$PATH
```

### Другие терминалы

Автоматическая активация ovm в других терминалах не гарантируется. Чаще всего она будет делаться по аналогии (в конфигурационных файлах), либо в настройках самого терминала.

Для `ConEmu` активация производится через `Settings` -> `Startup` -> `Environment`. В метод установки PATH необходимо добавить путь к %OVM_OSCRIPTBIN% перед текущим `%PATH%`. Например, `set PATH=%OVM_OSCRIPTBIN%;%PATH%`

Современные версии `Cmder` для Windows автоматически подхватывают переменные среды и переопределение автозапуска в реестре (см. <a href="use_cmd">Активация в cmd</a>)

## Использование

ovm - утилита командной строки, основанная на библиотеке [cli](https://github.com/khorevaa/cli). Утилита содержит несколько команд с различными аргументами и опциями. Каждая команда имеет длинное имя и короткий алиас. Каждый аргумент или опция могут быть установлены из переменных окружения либо указаны непосредственно в командной строке. Более подробно - в справке по библиотеке [cli](https://github.com/khorevaa/cli).

### Установка OneScript

Установка OneScript производится в пользовательский каталог, не захламляя общее системное пространство.

```sh
ovm install dev # Установить последнюю ночную сборку
ovm install dev stable 1.0.19 # Установить стабильную, ночную сборки и версию 1.0.19

ovm use --install dev # Активировать ночную сборку и установить, если ее нет
```

### Активация OneScript

Для запуска `oscript` и прочих утилит без указания путей к ним необходимо произвести активацию версии OneScript. При этом в каталоге данных `ovm` создастся специальная символическая ссылка `current`, ведущая на активированную версию.

```sh
ovm use dev # Активировать ранее установленную версию dev (ночную сборку)
ovm use --install dev # установить (если ее нет) и активировать версию dev
```

### Удаление OneScript

```sh
ovm delete 1.0.19 # Удалить установленную версию 1.0.19
```

### Вывод установленных версий OneScript

```sh
$ ovm ls # Вывод установленных версий

1.0.19 -> 1.0.19.105 (C:\Users\NikitaGryzlov\AppData\Local\ovm\1.0.19)
current -> 1.0.20.160 (C:\Users\NikitaGryzlov\AppData\Local\ovm\current)
dev -> 1.0.20.160 (C:\Users\NikitaGryzlov\AppData\Local\ovm\dev)
```

```sh
$ ovm ls --remote # Вывод версий, доступных к установке с сайта

1.0.19 (http://oscript.io/downloads/archive/1_0_19)
1.0.18 (http://oscript.io/downloads/archive/1_0_18)
```

```sh
$ ovm ls --all # Вывод всех версий - установленных и доступных

1.0.18 -> 1.0.18.101 -> C:\Users\NikitaGryzlov\AppData\Local\ovm\1.0.18 -> http://oscript.io/downloads/archive/1_0_18
1.0.19 -> 1.0.19.105 -> C:\Users\NikitaGryzlov\AppData\Local\ovm\1.0.19 -> http://oscript.io/downloads/archive/1_0_19
current -> 1.0.20.160 -> C:\Users\NikitaGryzlov\AppData\Local\ovm\current -> unknown
dev -> 1.0.20.160 -> C:\Users\NikitaGryzlov\AppData\Local\ovm\dev -> http://oscript.io/downloads
stable -> unknown -> not installed -> http://oscript.io/downloads
```

### Запуск приложений в окружении конкретной версии

ovm позволяет запускать приложения в окружении конкретной установленной версии OneScript. При этом происходит доустановка переменной окружения `PATH` к каталогу указанной версии.

```sh
$ ovm run 1.0.19 oscript -version # Выполнение команды oscript -version в окружении 1.0.19

1.0.19.105
```

```sh
$ ovm run 1.0.19 where oscript # Вывод сторонней команды where в окружении 1.0.19

C:\Users\NikitaGryzlov\AppData\Local\ovm\1.0.19\bin\oscript.exe # Путь к 1.0.19 указывается раньше, чем путь к current, благодаря запуску ovm run
C:\Users\NikitaGryzlov\AppData\Local\ovm\current\bin\oscript.exe
```

### Получение пути к исполняемому файлу oscript

```sh
$ ovm which 1.0.19

C:\Users\NikitaGryzlov\AppData\Local\ovm\1.0.19\bin\oscript.exe
```

## Конфигурирование ovm

ovm имеет несколько конфигурационных параметров, управляющих его поведением. Эти параметры можно задать с помощью команды `config`

### Синтаксис команды

```sh
$ ovm config <имя параметра> <значение>
```

### Настройка сайта с релизами

```sh
$ ovm config oscript.server https://internal.oscript.io
```

### Настройка прокси-сервера

При работе за корпоративным прокси-сервером может потребоваться указание настроек прокси.
Предусмотрены следующие параметры:

|Параметр|Возможное значение|Пояснение
|-|-|-
proxy.use|true/false|Включение использования прокси. Если параметр не задан - прокси не используется
|proxy.server|адрес прокси-сервера|Если параметр задан, то будут использованы ручные настройки прокси: имя сервера, порт, логин, пароль. Если параметр не задан, но задан proxy.use=true - используется системный прокси.
|proxy.port|Порт прокси-сервера|используется только если задан proxy.server
|proxy.user|Имя пользователя прокси-сервера|используется только если задан proxy.server
|proxy.password|Пароль прокси-сервера|используется только если задан proxy.server
|proxy.osAuthentication|true/false|Авторизация на прокси средствами ОС. Используется только если задан proxy.server

#### Пример использования

    # использование системного прокси
    ovm config proxy.use true

    # ручные настройки прокси
    ovm config proxy.use true
    ovm config proxy.server enterpise-proxy.server.lan
    ovm config proxy.osAuthentication true

## Вывод команды ovm

```
Приложение: ovm
 OneScript Version Manager v1.0.0-RC14

Строка запуска: ovm [ОПЦИИ] КОМАНДА [аргументы...]

Опции:
  -v, --version         показать версию и выйти

Доступные команды:
  install, i            Установить OneScript указанных версий
  use, u                Использовать OneScript указанной версии
  uninstall, delete, d  Удалить OneScript указанных версий
  list, ls              Вывести список установленных и/или доступных версий OneScript
  run, r                Запустить исполняемый файл в окружении указанной версии OneScript
  which, w              Вывести путь к установленной версии OneScript
  config                Настройки ovm. Прокси, сервера и т.п.

Для вывода справки по доступным командам наберите: ovm КОМАНДА --help
```
