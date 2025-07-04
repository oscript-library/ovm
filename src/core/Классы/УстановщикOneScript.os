#Использовать 1commands
#Использовать fs
#Использовать tempfiles
#Использовать strings

&ЛогOVM
Перем Лог;

&Пластилин
Перем ПараметрыOVM;

&Пластилин
Перем ВерсииOneScript;

&Пластилин
Перем ФабрикаИнтернетСоединения;

&Табакерка
&Пластилин("ОпределительДистрибутива")
Перем КоробочкаСОпределителями;

&Пластилин("ДетекторОкружения")
Перем Окружение;

&Желудь
Процедура ПриСозданииОбъекта()
КонецПроцедуры

// Конструктор дополнительных параметров установки OneScript
//
// Возвращаемое значение:
//  Структура - Дополнительные параметры установки:
//     * ОчищатьКаталогУстановки - Булево - Необходимость очистки каталога, в который устанавливается версия
//     * ИспользоватьХ64         - Булево - Устанавливать версию x64
//     * ИспользоватьFDD         - Булево - Устанавливать fdd дистрибутив версии 2.0
//
Функция ДополнительныеПараметрыУстановки() Экспорт

	Результат = Новый Структура;

	Результат.Вставить("ОчищатьКаталогУстановки", Истина);
	Результат.Вставить("ИспользоватьХ64", Ложь);
	Результат.Вставить("ИспользоватьFDD", Ложь);

	Возврат Результат;

КонецФункции

// Установка указанной версии OneScript.
// Допустимо использовать трех-разрядные номера версий и шорткаты dev и stable
//
// Параметры:
//   ВерсияКУстановке - Строка - Имя версии, которую необходимо установить
//   АлиасВерсии - Строка - Имя каталога, в который необходимо установить OneScript. По умолчанию совпадает и
//                          ВерсияКУстановке
//   ДополнительныеПараметры - см. УстановщикOneScript.ДополнительныеПараметрыУстановки
//
Процедура УстановитьOneScript(
	Знач ВерсияКУстановке,
	Знач АлиасВерсии = "",
	Знач ДополнительныеПараметры = Неопределено) Экспорт
	
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = ДополнительныеПараметрыУстановки();
	КонецЕсли;

	ОчищатьКаталогУстановки = ДополнительныеПараметры.ОчищатьКаталогУстановки;
	ИспользоватьХ64         = ДополнительныеПараметры.ИспользоватьХ64;
	ИспользоватьFDD         = ДополнительныеПараметры.ИспользоватьFDD;

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
		ФайлУстановщика = СкачатьФайлУстановщика(ВерсияКУстановке, ИспользоватьХ64, ИспользоватьFDD);
	
		УстановитьOneScriptИзZipАрхива(ФайлУстановщика, КаталогУстановкиВерсии);
		ДобавитьSHСкриптыПриНеобходимости(КаталогУстановкиВерсии);
		УстановитьРазрешениеДляSHСкриптовПриНеобходимости(КаталогУстановкиВерсии);
		ПодписатьOneScriptДляMacOS(КаталогУстановкиВерсии);

	Исключение
		УдалитьФайлы(КаталогУстановкиВерсии);
		ВызватьИсключение ОписаниеОшибки();	
	КонецПопытки;

	Лог.Информация("Установка OneScript %1 завершена", ВерсияКУстановке);
	Лог.Информация("");

КонецПроцедуры

Функция СкачатьФайлУстановщика(Знач ВерсияКУстановке, Знач ИспользоватьХ64, Знач ИспользоватьFDD)
	
	Лог.Информация("Скачиваю установщик версии %1%2...", ВерсияКУстановке, ?(ИспользоватьХ64, "-x64", ""));

	ПутьКСохраняемомуФайлу = ВременныеФайлы.НовоеИмяФайла("zip");
	
	Соединение = ФабрикаИнтернетСоединения.Создать();
	
	Ресурс = ПолучитьПутьКСкачиваниюФайла(ВерсияКУстановке, ИспользоватьХ64, ИспользоватьFDD);
	Запрос = Новый HTTPЗапрос(Ресурс);
	
	Лог.Отладка("Сервер: %1. Ресурс: %2", Соединение.Сервер, Ресурс);

	Ответ = Соединение.Получить(Запрос, ПутьКСохраняемомуФайлу);
	Лог.Отладка("Код состояния: %1", Ответ.КодСостояния);

	Лог.Информация("Скачивание завершено");

	HTTP_OK = 200;
	Если Ответ.КодСостояния <> HTTP_OK Тогда
		Лог.Ошибка(
			"Ошибка скачивания установщика. Текст ответа: 
			|%1", 
			Ответ.ПолучитьТелоКакСтроку()
		);
		ВызватьИсключение Ответ.КодСостояния;
	КонецЕсли;
	
	Лог.Отладка("Файл установщика скачан: %1", ПутьКСохраняемомуФайлу);
	
	Возврат ПутьКСохраняемомуФайлу;
	
КонецФункции

Процедура УстановитьOneScriptИзZipАрхива(Знач ПутьКФайлуУстановщика, Знач КаталогУстановкиВерсии)
	
	Лог.Информация("Распаковка OneScript...");

	ЧтениеZIPФайла = Новый ЧтениеZipФайла(ПутьКФайлуУстановщика);
	ЧтениеZIPФайла.ИзвлечьВсе(КаталогУстановкиВерсии);
	ЧтениеZIPФайла.Закрыть();
	
КонецПроцедуры

Процедура ДобавитьSHСкриптыПриНеобходимости(Знач КаталогУстановкиВерсии)
	
	Если Окружение.ЭтоWindows() Тогда
		Возврат;
	КонецЕсли;

	ПутьКСкрипту = ВерсииOneScript.ПутьКИсполняемомуФайлу(КаталогУстановкиВерсии);

	Если Не ФС.ФайлСуществует(ПутьКСкрипту + ".exe") Тогда
		ТекстСкрипта =
		"#!/bin/sh
		|dirpath=`dirname $0`
		|dotnet $dirpath/oscript.dll ""$@""
		|";
	Иначе
		ТекстСкрипта = 
		"#!/bin/sh
		|dirpath=`dirname $0`
		|mono $dirpath/oscript.exe ""$@""
		|";
	КонецЕсли;
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

КонецПроцедуры

Процедура УстановитьРазрешениеДляSHСкриптовПриНеобходимости(КаталогУстановкиВерсии)
	
	Если Окружение.ЭтоWindows() Тогда
		Возврат;
	КонецЕсли;

	ФайлыДляУстановкиРазрешений = Новый Массив;
	ФайлыДляУстановкиРазрешений.Добавить("opm");
	ФайлыДляУстановкиРазрешений.Добавить("opm.sh");
	ФайлыДляУстановкиРазрешений.Добавить("oscript");
	ФайлыДляУстановкиРазрешений.Добавить("oscript.sh");

	Для каждого Файл Из ФайлыДляУстановкиРазрешений Цикл

		ПутьКСкрипту = ОбъединитьПути(КаталогУстановкиВерсии, "bin", Файл);

		Если Не ФС.ФайлСуществует(ПутьКСкрипту) Тогда
			Продолжить;
		КонецЕсли;

		Лог.Отладка("Установка флага выполнения %1", ПутьКСкрипту);

		Команда = Новый Команда;
		Команда.УстановитьКоманду("chmod");
		Команда.ДобавитьПараметр("+x");
		Команда.ДобавитьПараметр(ПутьКСкрипту);
		Команда.УстановитьПравильныйКодВозврата(0);

		Команда.Исполнить();
		Лог.Отладка(Команда.ПолучитьВывод());

	КонецЦикла;

КонецПроцедуры

Функция ЭтоДопустимыйНомерВерсии(ВерсияКУстановке)
	РВ = Новый РегулярноеВыражение(ВерсииOneScript.МаскаНомераВерсииSemver());
	РВ.ИгнорироватьРегистр = Ложь;
	РВ.МногоСтрочный = Ложь;
	Возврат РВ.Совпадает(ВерсияКУстановке);
КонецФункции

Процедура ПроверитьКорректностьПереданнойВерсии(Знач ВерсияКУстановке)
	Если НЕ ЭтоДопустимыйНомерВерсии(ВерсияКУстановке)
		И Не ВерсииOneScript.ДопустимыеАлиасы().СодержитКлюч(ВерсияКУстановке) Тогда
		
		Лог.Ошибка("Версия имеет некорректный формат");

		ВызватьИсключение ВерсияКУстановке;
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьПутьКСкачиваниюФайла(Знач ВерсияКУстановке, Знач ИспользоватьХ64, Знач ИспользоватьFDD)

	ОпределительДистрибутива = КоробочкаСОпределителями.Достать()
		.ИспользоватьХ64(ИспользоватьХ64)
		.ИспользоватьFDD(ИспользоватьFDD);

	Если ЭтоДопустимыйНомерВерсии(ВерсияКУстановке) Тогда

		ИскомаяВерсия = ВерсияКУстановке;
		ОпределительДистрибутива.ЭтоДистрибутивНеткор(СтроковыеФункции.СравнитьВерсии(ВерсияКУстановке, "2.0") >= 0);

	Иначе

		ДанныеВерсии = ВерсииOneScript.ДопустимыеАлиасы()
			.Получить(ВерсияКУстановке)
			.ИначеВызватьИсключение("Ошибка получения пути к файлу по версии");

		ИскомаяВерсия = ДанныеВерсии.Метка;

	КонецЕсли;

	ПереченьФайлов = ВерсииOneScript.ПолучитьДоступныеВидыДистрибутивовВерсии(ИскомаяВерсия);

	Возврат ОпределительДистрибутива.Выбрать(ПереченьФайлов);

КонецФункции

Функция ПроверитьВозможностьУстановкиX64(ВерсияКУстановке)
	
	Возврат ВерсииOneScript.ДопустимыеАлиасы().СодержитКлюч(ВерсияКУстановке)
		Или СтроковыеФункции.СравнитьВерсии(ВерсияКУстановке, "1.2.0") >= 0;

КонецФункции

Процедура ПодписатьOneScriptДляMacOS(КаталогУстановкиВерсии)

	Если Не Окружение.ЭтоMacOS() Тогда
		Возврат;
	КонецЕсли;

	Команда = Новый Команда;

	Команда.УстановитьКоманду("codesign");
	Команда.ДобавитьПараметр("-f");
	Команда.ДобавитьПараметр("-s");
	Команда.ДобавитьПараметр("-");
	Команда.ДобавитьПараметр(ВерсииOneScript.ПутьКИсполняемомуФайлу(КаталогУстановкиВерсии));

	Команда.УстановитьПравильныйКодВозврата(0);

	Команда.Исполнить();

	Лог.Отладка(Команда.ПолучитьВывод());

КонецПроцедуры
