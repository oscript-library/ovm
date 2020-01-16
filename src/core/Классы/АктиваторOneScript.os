#Использовать 1commands
#Использовать fs

Перем СистемнаяИнформация;
Перем ЭтоWindows;
Перем Лог;

// Активирует указанную версию OneScript.
// Создает необходимые симлинки и оперирует PATH.
//
// Параметры:
//   ИспользуемаяВерсия - Строка - Алиас версии, которую необходимо активировать
//   ВыполнятьУстановкуПриНеобходимости - Булево - Флаг, управляющей запуском установки в случае, если активируемый
//                                                 алиас не установлен 
//
Процедура ИспользоватьВерсиюOneScript(Знач ИспользуемаяВерсия, Знач ВыполнятьУстановкуПриНеобходимости = Ложь) Экспорт
	
	Лог.Информация("Активация версии OneScript %1", ИспользуемаяВерсия);

	ПроверитьНаличиеИспользуемойВерсии(ИспользуемаяВерсия, ВыполнятьУстановкуПриНеобходимости);
	
	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ИспользуемаяВерсия);
	
	ПутьКОбщемуКаталогуOneScript = ОбъединитьПути(КаталогУстановки, "current");
	
	НадоВывестиИнформационноеСообщение = НЕ ФС.КаталогСуществует(ПутьКОбщемуКаталогуOneScript);

	СоздатьСимЛинкНаКаталог(ПутьКОбщемуКаталогуOneScript, КаталогУстановкиВерсии);
	ДобавитьКаталогBinВPath(ОбъединитьПути(ПутьКОбщемуКаталогуOneScript, "bin"));
	
	Если НадоВывестиИнформационноеСообщение Тогда
		Лог.Предупреждение("ВНИМАНИЕ: Переоткройте терминал после первого использования ovm use.");
	КонецЕсли;

	Лог.Информация("OneScript %1 активирован", ИспользуемаяВерсия);

КонецПроцедуры

Процедура СоздатьСимЛинкНаКаталог(Знач Ссылка, Знач ПутьНазначения)
	
	ПутьКСсылке = Новый Файл(Ссылка).ПолноеИмя;
	ПутьККаталогуНазначения = Новый Файл(ПутьНазначения).ПолноеИмя;

	Лог.Отладка("Создаю символическую ссылку %1 на %2", ПутьКСсылке, ПутьККаталогуНазначения);

	Если ФС.КаталогСуществует(ПутьКСсылке) Тогда 
		
		Лог.Отладка("Удаляю старую символическую ссылку");

		Если ЭтоWindows Тогда 
			УдалитьФайлы(ПутьКСсылке); 
		Иначе 
			Команда = Новый Команда; 
			Команда.УстановитьКоманду("unlink");
			Команда.ДобавитьПараметр(ПутьКСсылке);
			Команда.УстановитьПравильныйКодВозврата(0);
			Команда.Исполнить();

			Лог.Отладка(Команда.ПолучитьВывод());
		КонецЕсли; 
	КонецЕсли;
	
	Лог.Отладка("Выполняю создание символической ссылки");
	
	Если ЭтоWindows Тогда
		Команда = Новый Команда;
		Команда.УстановитьКоманду("mklink");
		Команда.ДобавитьПараметр("/J");
		Команда.ДобавитьПараметр(ПутьКСсылке);
		Команда.ДобавитьПараметр(ПутьККаталогуНазначения);
		Команда.УстановитьПравильныйКодВозврата(0);
		
		Команда.Исполнить();
		Лог.Отладка(Команда.ПолучитьВывод());
	Иначе
		Команда = Новый Команда;
		Команда.УстановитьКоманду("ln");
		Команда.ДобавитьПараметр("-s");
		Команда.ДобавитьПараметр(ПутьККаталогуНазначения);
		Команда.ДобавитьПараметр(ПутьКСсылке);
		Команда.УстановитьПравильныйКодВозврата(0);
		
		Команда.Исполнить();

		Лог.Отладка(Команда.ПолучитьВывод());
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКаталогBinВPath(Знач ПутьККаталогуBin)
	
	Лог.Отладка("Добавляю каталог %1 в PATH", ПутьККаталогуBin);
	
	Если ЭтоWindows Тогда
		ПеременнаяPATH = ПолучитьПеременнуюСредыИзРеестра("PATH", РасположениеПеременнойСреды.Пользователь);
		ИскомоеЗначение = "%OVM_OSCRIPTBIN%";
	Иначе
		ПеременнаяPATH = ПолучитьПеременнуюСреды("PATH", РасположениеПеременнойСреды.Пользователь);
		ПутьКаталогуHOME = ПолучитьПеременнуюСреды("HOME");
		Если НЕ ПустаяСтрока(ПутьКаталогуHOME) Тогда
			ПутьККаталогуBin = СтрЗаменить(ПутьККаталогуBin, ПутьКаталогуHOME, "$HOME");
		КонецЕсли;
		ИскомоеЗначение = ПутьККаталогуBin;
	КонецЕсли;
	
	Если ЭтоWindows Тогда
		СоздатьПереопределенияPATHДляКомандногоПроцессора_Windows();
	КонецЕсли;
	
	Если СтрНайти(ПеременнаяPATH, ИскомоеЗначение) <> 0 Тогда
		Лог.Отладка("PATH уже содержит путь к каталогу");
		Возврат;
	КонецЕсли;
	
	Если ЭтоWindows Тогда
		Лог.Отладка("Установка переменных среды на уровне пользователя");
		ЗначениеПеременнойСреды = "%OVM_OSCRIPTBIN%;" + ПеременнаяPATH;
		УстановитьПеременнуюСредыВРеестре("PATH", "REG_EXPAND_SZ", ЗначениеПеременнойСреды,
			РасположениеПеременнойСреды.Пользователь);
		УстановитьПеременнуюСредыСОповещением("OVM_OSCRIPTBIN", ПутьККаталогуBin,
			РасположениеПеременнойСреды.Пользователь);
	Иначе
		СоздатьПереопределенияPATHДляКомандногоПроцессора_Unix(ПутьККаталогуBin);
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьТекстВНовыйИлиИмеющийсяФайл(Знач ДобавляемыйТекст, Знач ПутьКФайлу)
	
	Если ЭтоWindows Тогда
		РазделительСтрок = Символы.ВК + Символы.ПС;
	Иначе
		РазделительСтрок = Символы.ПС;
	КонецЕсли;

	Лог.Отладка(
		"Добавление текста в файл.
		|Текст:
		|%1
		|Файл:
		|%2",
		ДобавляемыйТекст,
		ПутьКФайлу
	);

	Если НЕ ФС.ФайлСуществует(ПутьКФайлу) Тогда
		Лог.Отладка("Файл не существует, создаю новый");

		Файл = Новый Файл(ПутьКФайлу);
		ФС.ОбеспечитьКаталог(Файл.Путь);
		
		ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу, КодировкаТекста.UTF8NoBOM, , , РазделительСтрок);
		ЗаписьТекста.Записать("");
		ЗаписьТекста.Закрыть();
	КонецЕсли;

	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу);
	НайденныйДобавляемыйТекст = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	Если СтрНайти(НайденныйДобавляемыйТекст, ДобавляемыйТекст) <> 0 Тогда
		Лог.Отладка("Файл уже содержит добавляемый текст");
		Возврат;
	КонецЕсли;
	
	ЗаписьТекста = Новый ЗаписьТекста();
	ЗаписьТекста.Открыть(ПутьКФайлу, КодировкаТекста.UTF8NoBOM, , Истина, РазделительСтрок);
	
	ЗаписьТекста.ЗаписатьСтроку(ДобавляемыйТекст);
	ЗаписьТекста.Закрыть();
	
	Лог.Отладка("Текст добавлен в файл");
	
КонецПроцедуры

Процедура СоздатьПереопределенияPATHДляКомандногоПроцессора_Windows()
	
	Если НЕ ИспользуетсяСистемныйOneScript() Тогда
		Лог.Отладка("Системный OneScript не найден");
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Добавление ovm в автозапуск cmd");
	
	ТекстВычислениеPATH = "set PATH=%OVM_OSCRIPTBIN%;%PATH%";
	
	СтрокаЗапуска = СтрШаблон(
			"REG ADD ""HKCU\Software\Microsoft\Command Processor"" /v Autorun /t REG_SZ /f /d ""%1""",
			ТекстВычислениеPATH
		);
	
	Лог.Отладка("Строка запуска
		|%1", СтрЗаменить(СтрокаЗапуска, "%", "%%"));
	
	Команда = Новый Команда;
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
	Команда.УстановитьПравильныйКодВозврата(0);
	
	Команда.Исполнить();
	
	ВыводКоманды = Команда.ПолучитьВывод();
	Лог.Отладка(ВыводКоманды);
	
	Лог.Отладка("Добавление ovm в автозапуск powershell");
	
	ПутьКФайлу = ОбъединитьПути(
			СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ПрофильПользователя),
			"Documents",
			"WindowsPowerShell",
			"profile.ps1"
		);
	
	ТекстВычислениеPATH = "set PATH=$OVM_OSCRIPTBIN;$PATH";
	ДобавитьТекстВНовыйИлиИмеющийсяФайл(ТекстВычислениеPATH, ПутьКФайлу);
	
КонецПроцедуры

Процедура СоздатьПереопределенияPATHДляКомандногоПроцессора_Unix(Знач ПутьККаталогуBin)
	
	Лог.Отладка("Добавление каталога в PATH для shell");
	ТекстФайлаПрофиля = "export PATH=""" + ПутьККаталогуBin + ":$PATH""
		|export OSCRIPTBIN=""" + ПутьККаталогуBin + """";
	
	ПутьКФайлу = ОбъединитьПути(
			СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ПрофильПользователя),
			".profile"
		);
	
	ДобавитьТекстВНовыйИлиИмеющийсяФайл(ТекстФайлаПрофиля, ПутьКФайлу);
	
	ПутьКФайлу = ОбъединитьПути(
			СистемнаяИнформация.ПолучитьПутьПапки(СпециальнаяПапка.ПрофильПользователя),
			".bashrc"
		);
	
	ДобавитьТекстВНовыйИлиИмеющийсяФайл(ТекстФайлаПрофиля, ПутьКФайлу);
	
КонецПроцедуры

Процедура ПроверитьНаличиеИспользуемойВерсии(Знач ИспользуемаяВерсия, Знач ВыполнятьУстановкуПриНеобходимости)
	
	Если ВерсииOneScript.ВерсияУстановлена(ИспользуемаяВерсия) Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыполнятьУстановкуПриНеобходимости Тогда
		УстановщикOneScript = Новый УстановщикOneScript();
		УстановщикOneScript.УстановитьOneScript(ИспользуемаяВерсия);
	Иначе
		ВызватьИсключение СтрШаблон("Не обнаружена требуемая версия <%1>", ИспользуемаяВерсия);
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьПеременнуюСредыВРеестре(
		Знач ИмяПеременнойСреды,
		Знач ТипПеременнойСреды,
		Знач ЗначениеПеременнойСреды,
		Знач _РасположениеПеременнойСреды
	)
	
	Если _РасположениеПеременнойСреды = РасположениеПеременнойСреды.Машина Тогда
		РазделПеременнойСреды = """HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment""";
	Иначе
		// РасположениеПеременнойСреды.Пользователь;
		РазделПеременнойСреды = "HKCU\Environment";
	КонецЕсли;
	
	Команда = Новый Команда();
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	
	Команда.УстановитьКоманду("reg.exe");
	
	Команда.ДобавитьПараметр("add");
	
	Команда.ДобавитьПараметр(РазделПеременнойСреды);
	
	Команда.ДобавитьПараметр("/v");
	Команда.ДобавитьПараметр(ИмяПеременнойСреды);
	
	Команда.ДобавитьПараметр("/f");
	
	Команда.ДобавитьПараметр("/t");
	Команда.ДобавитьПараметр(ТипПеременнойСреды);
	
	Команда.ДобавитьПараметр("/d");
	Команда.ДобавитьПараметр(Команда.ОбернутьВКавычки(ЗначениеПеременнойСреды));
	
	КодВозврата = Команда.Исполнить();
	
	Если КодВозврата <> 0 Тогда
		ВыводКоманды = Команда.ПолучитьВывод();
		
		ВызватьИсключение СтрШаблон(
			"Ошибка установки значения переменной %1.
			|Код возврата: %2
			|Текст ошибки: %3",
			ИмяПеременнойСреды,
			КодВозврата,
			ВыводКоманды
		);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьПеременнуюСредыИзРеестра(
		Знач ИмяПеременнойСреды,
		Знач _РасположениеПеременнойСреды
	)
	
	Если _РасположениеПеременнойСреды = РасположениеПеременнойСреды.Машина Тогда
		РазделПеременнойСреды = """HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment""";
	Иначе
		// РасположениеПеременнойСреды.Пользователь;
		РазделПеременнойСреды = "HKCU\Environment";
	КонецЕсли;
	
	Команда = Новый Команда();
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	
	Команда.УстановитьКоманду("reg.exe");
	
	Команда.ДобавитьПараметр("query");
	
	Команда.ДобавитьПараметр(РазделПеременнойСреды);
	
	Команда.ДобавитьПараметр("/v");
	Команда.ДобавитьПараметр(ИмяПеременнойСреды);
	
	КодВозврата = Команда.Исполнить();
	ВыводКоманды = Команда.ПолучитьВывод();
	
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение СтрШаблон(
			"Ошибка получения значения переменной %1.
			|Код возврата: %2
			|Текст ошибки: %3",
			ИмяПеременнойСреды,
			КодВозврата,
			ВыводКоманды
		);
	КонецЕсли;
	
	НомерСтрокиСДанными = 2;
	СтрокаСДанными = СтрЗаменить(СтрПолучитьСтроку(ВыводКоманды, НомерСтрокиСДанными), "    ", Символы.ПС);
	
	НомерСтрокиСоЗначением = 4;
	ЗначениеПеременной = СтрПолучитьСтроку(СтрокаСДанными, НомерСтрокиСоЗначением);
	
	Возврат ЗначениеПеременной;
	
КонецФункции

Процедура УстановитьПеременнуюСредыСОповещением(
		Знач ИмяПеременнойСреды,
		Знач ЗначениеПеременнойСреды,
		Знач _РасположениеПеременнойСреды
	)
	
	Команда = Новый Команда();
	Команда.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	
	Команда.УстановитьКоманду("setx.exe");
	
	Если _РасположениеПеременнойСреды = РасположениеПеременнойСреды.Машина Тогда
		Команда.ДобавитьПараметр("/m");
	КонецЕсли;
	
	Команда.ДобавитьПараметр(ИмяПеременнойСреды);
	Команда.ДобавитьПараметр(Команда.ОбернутьВКавычки(ЗначениеПеременнойСреды));
	
	КодВозврата = Команда.Исполнить();
	
	Если КодВозврата <> 0 Тогда
		ВыводКоманды = Команда.ПолучитьВывод();
		
		ВызватьИсключение СтрШаблон(
			"Ошибка установки переменной среды %1.
			|Код возврата: %2
			|Текст ошибки: %3",
			ИмяПеременнойСреды,
			КодВозврата,
			ВыводКоманды
		);
	КонецЕсли;
	
КонецПроцедуры

Функция ИспользуетсяСистемныйOneScript()
	Лог.Отладка("Определяю путь к дефолтному oscript");
	
	Команда = Новый Команда;
	Команда.УстановитьКоманду("where");
	Команда.ДобавитьПараметр("oscript");
	Команда.УстановитьПравильныйКодВозврата(0);
	
	Команда.Исполнить();
	
	ВыводКоманды = Команда.ПолучитьВывод();
	Лог.Отладка(ВыводКоманды);
	
	ПутьКДефолтномуOneScript = СтрПолучитьСтроку(ВыводКоманды, 1);
	Лог.Отладка("Путь к дефолтному OneScript: %1", ПутьКДефолтномуOneScript);
	
	Результат = СтрНайти(ПутьКДефолтномуOneScript, ПолучитьРазделительПути() + "ovm" + ПолучитьРазделительПути()) = 0;
	
	Возврат Результат;
	
КонецФункции

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;
Лог = ПараметрыOVM.ПолучитьЛог();
