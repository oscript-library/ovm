#Использовать 1commands
#Использовать fs
#Использовать tempfiles
#Использовать logos
#Использовать strings

Перем ЭтоWindows;
Перем Лог;

// Установка указанной версии OneScript.
// Допустимо использовать трех-разрядные номера версий и шорткаты dev и stable
//
// Параметры:
//   ВерсияКУстановке - Строка - Имя версии, которую необходимо установить
//   АлиасВерсии - Строка - Имя каталога, в который необходимо установить OneScript. По умолчанию совпадает и
//                          ВерсияКУстановке
//   ОчищатьКаталогУстановки - Булево - Необходимость очистки каталога, в который устанавливается версия.
//
Процедура УстановитьOneScript(
	Знач ВерсияКУстановке, 
	Знач АлиасВерсии = "", 
	Знач ОчищатьКаталогУстановки = Истина,
	Знач ИспользоватьХ64 = Ложь
) Экспорт
	
	Если ИспользоватьХ64 Тогда
		ИспользоватьХ64 = ПроверитьВозможностьУстановкиX64(ВерсияКУстановке);
	КонецЕсли;

	Лог.Информация("Установка OneScript %1...", ВерсияКУстановке);
	
	Если НЕ ЗначениеЗаполнено(АлиасВерсии) Тогда
		АлиасВерсии = ВерсияКУстановке;
	КонецЕсли;

	ПроверитьКорректностьПереданнойВерсии(ВерсияКУстановке);
	
	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, АлиасВерсии);
	
	ФС.ОбеспечитьКаталог(КаталогУстановки);
	Если ОчищатьКаталогУстановки Тогда
		ФС.ОбеспечитьПустойКаталог(КаталогУстановкиВерсии);
	Иначе
		ФС.ОбеспечитьКаталог(КаталогУстановкиВерсии);
	КонецЕсли;

	Лог.Отладка("Каталог установки версии: %1", КаталогУстановкиВерсии);

	Попытка
		ФайлУстановщика = СкачатьФайлУстановщика(ВерсияКУстановке, ИспользоватьХ64);
	
		УстановитьOneScriptИзZipАрхива(ФайлУстановщика, КаталогУстановкиВерсии);
		ДобавитьSHСкриптыПриНеобходимости(КаталогУстановкиВерсии, ВерсияКУстановке);
	Исключение
		УдалитьФайлы(КаталогУстановкиВерсии);
		ВызватьИсключение ОписаниеОшибки();	
	КонецПопытки;

	Лог.Информация("Установка OneScript %1 завершена", ВерсияКУстановке);
	Лог.Информация("");

КонецПроцедуры

Функция СкачатьФайлУстановщика(Знач ВерсияКУстановке, Знач ИспользоватьХ64)
	
	АдресСайтаОСкрипт = ПараметрыOVM.АдресСайтаОСкрипт();
	ПутьКСохраняемомуФайлу = "";

	Если ТипЗнч(АдресСайтаОСкрипт) = Тип("Массив") Тогда
		
		Для Каждого АдресЗеркала Из АдресСайтаОСкрипт Цикл
			Попытка
				ПутьКСохраняемомуФайлу = СкачатьФайлУстановщикаССайта(
					АдресЗеркала,
					ВерсияКУстановке,
					ИспользоватьХ64);
				Прервать;
			Исключение
				Продолжить;
			КонецПопытки;
			
		КонецЦикла;
		
		Если Не ЗначениеЗаполнено(ПутьКСохраняемомуФайлу) Тогда
			ВызватьИсключение "Не удалось скачать файл!";
		КонецЕсли;

	Иначе
		ПутьКСохраняемомуФайлу = СкачатьФайлУстановщикаССайта(
			АдресСайтаОСкрипт,
			ВерсияКУстановке,
			ИспользоватьХ64);
	КонецЕсли;
	
	Возврат ПутьКСохраняемомуФайлу;
	
КонецФункции

Функция СкачатьФайлУстановщикаССайта(Знач АдресСайтаОСкрипт, Знач ВерсияКУстановке, Знач ИспользоватьХ64)
	
	Лог.Информация("Скачиваю установщик версии %1%2 с сайта %3...",
		ВерсияКУстановке,
		?(ИспользоватьХ64, "-x64", ""),
		АдресСайтаОСкрипт);

	ПутьКСохраняемомуФайлу = ВременныеФайлы.НовоеИмяФайла("zip");
	
	СерверПрокси = ПараметрыOVM.ЗначениеНастройки("proxy.server");
	ИспользоватьПрокси = ПараметрыOVM.ЗначениеНастройки("proxy.use");

	Если ИспользоватьПрокси = "true" Тогда
		Если Не ЗначениеЗаполнено(СерверПрокси) Тогда
			Лог.Отладка("Использую системный прокси");
			Прокси = Новый ИнтернетПрокси(Истина);
		ИначеЕсли ЗначениеЗаполнено(СерверПрокси) Тогда
			Лог.Отладка("Использую прокси %1", ПараметрыOVM.ЗначениеНастройки("proxy.server"));
			Прокси = Новый ИнтернетПрокси();
			Прокси.Установить("http",
				ПараметрыOVM.ЗначениеНастройки("proxy.server"),
				ПараметрыOVM.ЗначениеНастройки("proxy.port"),
				ПараметрыOVM.ЗначениеНастройки("proxy.user"),
				ПараметрыOVM.ЗначениеНастройки("proxy.password"),
				ПараметрыOVM.ЗначениеНастройки("proxy.osAuthentication"));

			Прокси.Установить("https",
				ПараметрыOVM.ЗначениеНастройки("proxy.server"),
				ПараметрыOVM.ЗначениеНастройки("proxy.port"),
				ПараметрыOVM.ЗначениеНастройки("proxy.user"),
				ПараметрыOVM.ЗначениеНастройки("proxy.password"),
				ПараметрыOVM.ЗначениеНастройки("proxy.osAuthentication"));
		КонецЕсли;
	Иначе
		Лог.Отладка("Прокси не используется");
		Прокси = Неопределено;
	КонецЕсли;

	Таймаут = 10;
	Соединение = Новый HTTPСоединение(
		АдресСайтаОСкрипт,
		,
		,
		,
		Прокси,
		Таймаут
	);
	
	Ресурс = ПолучитьПутьКСкачиваниюФайла(ВерсияКУстановке, ИспользоватьХ64);
	Запрос = Новый HTTPЗапрос(Ресурс);
	
	Лог.Отладка("Сервер: %1. Ресурс: %2", Соединение.Сервер, Ресурс);

	Ответ = Соединение.Получить(Запрос, ПутьКСохраняемомуФайлу);
	Лог.Отладка("Код состояния: %1", Ответ.КодСостояния);

	Лог.Информация("Скачивание завершено");

	HTTP_OK = 200;
	ОжидаыемыеТипыДанных = Новый Массив;
	ОжидаыемыеТипыДанных.Добавить("application/octet-stream");
	ОжидаыемыеТипыДанных.Добавить("application/zip");
	ТипДанных = Ответ.Заголовки["Content-Type"];
	Если Ответ.КодСостояния <> HTTP_OK Тогда
		Лог.Ошибка(
			"Ошибка скачивания установщика. Текст ответа: 
			|%1", 
			Ответ.ПолучитьТелоКакСтроку()
		);
		ВызватьИсключение Ответ.КодСостояния;
	ИначеЕсли ОжидаыемыеТипыДанных.Найти(ТипДанных) = Неопределено Тогда
		Лог.Ошибка(
			"Ошибка скачивания установщика. Неверный тип данных: 
			|%1",
			ТипДанных
		);
		ВызватьИсключение Ответ.КодСостояния;
	Иначе
		Лог.Отладка("Файл установщика скачан: %1", ПутьКСохраняемомуФайлу);
	КонецЕсли;
	
	Возврат ПутьКСохраняемомуФайлу;
	
КонецФункции

Процедура УстановитьOneScriptИзZipАрхива(Знач ПутьКФайлуУстановщика, Знач КаталогУстановкиВерсии)
	
	Лог.Информация("Распаковка OneScript...");

	ЧтениеZIPФайла = Новый ЧтениеZipФайла(ПутьКФайлуУстановщика);
	ЧтениеZIPФайла.ИзвлечьВсе(КаталогУстановкиВерсии);
	ЧтениеZIPФайла.Закрыть();
	
КонецПроцедуры

Процедура ДобавитьСкриптыДляdotnet(Знач КаталогУстановкиВерсии)

	КаталогИсполняемыхФайлов = ОбъединитьПути(КаталогУстановкиВерсии, "bin");

	Если ЭтоWindows Тогда
		ПутьКСкрипту = ОбъединитьПути(КаталогИсполняемыхФайлов, "oscript.bat");
		ТекстСкрипта =
		"@echo off
		|@setlocal
		|@set BINROOT=%~dp0
		|dotnet %BINROOT%\oscript.dll %*
		|";
		
		ДобавитьBatСкрипт(ПутьКСкрипту, ТекстСкрипта);
	
	Иначе
		
		ПутьКСкрипту = ОбъединитьПути(КаталогИсполняемыхФайлов, "oscript");
		ТекстСкрипта = 
		"#!/bin/sh
		|dirpath=`dirname $0`
		|dotnet $dirpath/oscript.dll ""$@""
		|";
		
		ДобавитьShСкрипт(ПутьКСкрипту, ТекстСкрипта);

		ПутьКСкрипту = ОбъединитьПути(КаталогИсполняемыхФайлов, "opm");
		ТекстСкрипта = 
		"#!/bin/sh
		|dirpath=`dirname $0`
		|opmpath=$dirpath/../lib/opm/src/opm.os
		|if [ ! -f ""$opmpath"" ]; then
		|	opmpath=$dirpath/../lib/opm/src/cmd/opm.os
		|fi
		|oscript ""$opmpath"" ""$@""
		|";
		
		ДобавитьShСкрипт(ПутьКСкрипту, ТекстСкрипта);

	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьSHСкриптыПриНеобходимости(Знач КаталогУстановкиВерсии, Знач ВерсияКУстановке)

	Если СтрНачинаетсяС(ВерсияКУстановке, "2.0") Тогда
		ДобавитьСкриптыДляdotnet(КаталогУстановкиВерсии);
		Возврат;
	КонецЕсли;
	
	Если ЭтоWindows Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКСкрипту = ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript");
	ТекстСкрипта = 
	"#!/bin/sh
	|dirpath=`dirname $0`
	|mono $dirpath/oscript.exe ""$@""
	|";
	
	ДобавитьShСкрипт(ПутьКСкрипту, ТекстСкрипта);

	ПутьКСкрипту = ОбъединитьПути(КаталогУстановкиВерсии, "bin", "opm");
	ТекстСкрипта = 
	"#!/bin/sh
	|dirpath=`dirname $0`
	|opmpath=$dirpath/../lib/opm/src/opm.os
	|if [ ! -f ""$opmpath"" ]; then
	|	opmpath=$dirpath/../lib/opm/src/cmd/opm.os
	|fi
	|oscript ""$opmpath"" ""$@""
	|";
	
	ДобавитьShСкрипт(ПутьКСкрипту, ТекстСкрипта);

КонецПроцедуры

Процедура ДобавитьShСкрипт(Знач ПутьКСкрипту, Знач ТекстСкрипта)
	
	Лог.Информация("Создание sh-скрипта %1...", Новый Файл(ПутьКСкрипту).ИмяБезРасширения);

	Лог.Отладка("Путь с sh-скрипту: %1", ПутьКСкрипту);
	
	Лог.Отладка(
		"Текст скрипта: 
		|%1",
		ТекстСкрипта
	);
	
	Если ФС.ФайлСуществует(ПутьКСкрипту) Тогда
		Лог.Отладка("sh-скрипт уже существует");
		Возврат;
	КонецЕсли;

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСкрипту, КодировкаТекста.UTF8NoBOM, , , Символы.ПС);
	
	ЗаписьТекста.Записать(ТекстСкрипта);
	ЗаписьТекста.Закрыть();
	
	Лог.Отладка("Установка флага выполнения...");

	Команда = Новый Команда;
	Команда.УстановитьКоманду("chmod");
	Команда.ДобавитьПараметр("+x");
	Команда.ДобавитьПараметр(ПутьКСкрипту);
	Команда.УстановитьПравильныйКодВозврата(0);
	
	Команда.Исполнить();
	Лог.Отладка(Команда.ПолучитьВывод());

КонецПроцедуры

Процедура ДобавитьBatСкрипт(Знач ПутьКСкрипту, Знач ТекстСкрипта)
	
	Лог.Информация("Создание batch-скрипта %1...", Новый Файл(ПутьКСкрипту).ИмяБезРасширения);

	Лог.Отладка("Путь с batch-скрипту: %1", ПутьКСкрипту);
	
	Лог.Отладка(
		"Текст скрипта: 
		|%1",
		ТекстСкрипта
	);
	
	Если ФС.ФайлСуществует(ПутьКСкрипту) Тогда
		Лог.Отладка("batch-скрипт уже существует");
		Возврат;
	КонецЕсли;

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСкрипту, КодировкаТекста.ANSI);
	
	ЗаписьТекста.Записать(ТекстСкрипта);
	ЗаписьТекста.Закрыть();
	
КонецПроцедуры

Процедура ПроверитьКорректностьПереданнойВерсии(Знач ВерсияКУстановке)
	Если СтрРазделить(ВерсияКУстановке, ".").Количество() <> ПараметрыOVM.КоличествоРазрядовВНомереВерсии()
		И НРег(ВерсияКУстановке) <> "stable"
		И НРег(ВерсияКУстановке) <> "dev" Тогда
		
		Лог.Ошибка("Версия имеет некорректный формат");

		ВызватьИсключение ВерсияКУстановке;
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьПутьКСкачиваниюФайла(Знач ВерсияКУстановке, Знач ИспользоватьХ64)
	
	Если СтрРазделить(ВерсияКУстановке, ".").Количество() = ПараметрыOVM.КоличествоРазрядовВНомереВерсии() Тогда
		КаталогВерсии = СтрЗаменить(ВерсияКУстановке, ".", "_");
	ИначеЕсли НРег(ВерсияКУстановке) = "stable" Тогда
		КаталогВерсии = "latest";
	ИначеЕсли НРег(ВерсияКУстановке) = "dev" Тогда
		КаталогВерсии = "night-build";
	Иначе
		ВызватьИсключение "Ошибка получения пути к файлу по версии";
	КонецЕсли;
	ИмяФайла = "zip";
	
	Если СтрНачинаетсяС(ВерсияКУстановке, "2.0") Тогда
		ИмяФайла = СтрШаблон("OneScript-%1-fdd-%2.zip",
			ВерсияКУстановке,
			?(ИспользоватьХ64, "x64", "x86"));
	КонецЕсли;
	
	ЧастиПути = Новый Массив;
	ЧастиПути.Добавить("downloads");
	ЧастиПути.Добавить(КаталогВерсии);
	Если ИспользоватьХ64 Тогда
		ЧастиПути.Добавить("x64");
	КонецЕсли;
	ЧастиПути.Добавить(ИмяФайла);

	Ресурс = СтрСоединить(ЧастиПути, "/");
	Возврат Ресурс;
	
КонецФункции

Функция ПроверитьВозможностьУстановкиX64(ВерсияКУстановке)
	// Версия х64 доступна для версий 1.2.0 и выше
	Если НРег(ВерсияКУстановке) = "stable"
		Или НРег(ВерсияКУстановке) = "dev" Тогда
		Возврат Истина;
	Иначе
		Возврат СтроковыеФункции.СравнитьВерсии(ВерсияКУстановке, "1.2.0") >= 0;
	КонецЕсли;
КонецФункции

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

Лог = ПараметрыOVM.ПолучитьЛог();
