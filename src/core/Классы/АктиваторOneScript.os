#Использовать fs

Перем ЭтоWindows;

Процедура ИспользоватьВерсиюOneScript(Знач ИспользуемаяВерсия, Знач ВыполнятьУстановкуПриНеобходимости) Экспорт
	
	ПроверитьНаличиеИспользуемойВерсии(ИспользуемаяВерсия, ВыполнятьУстановкуПриНеобходимости);
	
	КаталогУстановки = ПараметрыПриложения.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ИспользуемаяВерсия);
	
	ПутьКОбщемуКаталогуOneScript = ОбъединитьПути(КаталогУстановки, "current");
	УдалитьФайлы(ПутьКОбщемуКаталогуOneScript);
	
	СоздатьСимЛинкНаКаталог(ПутьКОбщемуКаталогуOneScript, КаталогУстановкиВерсии);
	ДобавитьКаталогBinВPath(ОбъединитьПути(ПутьКОбщемуКаталогуOneScript, "bin"));
	
КонецПроцедуры

Процедура СоздатьСимЛинкНаКаталог(Знач Ссылка, Знач ПутьНазначения)
	
	Если ЭтоWindows Тогда
		Команда = Новый Команда;
		Команда.УстановитьКоманду("mklink");
		Команда.ДобавитьПараметр("/D");
		Команда.ДобавитьПараметр(Ссылка);
		Команда.ДобавитьПараметр(ПутьНазначения);
		
		Команда.Исполнить();
	Иначе
		Команда = Новый Команда;
		Команда.УстановитьКоманду("ln");
		Команда.ДобавитьПараметр("-s");
		Команда.ДобавитьПараметр(ПутьНазначения);
		Команда.ДобавитьПараметр(Ссылка);
		
		Команда.Исполнить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКаталогBinВPath(Знач ПутьККаталогуBin)
	
	ПеременнаяPATH = ПолучитьПеременнуюСреды("PATH");
	Если СтрНайти(ПеременнаяPATH, ПутьККаталогуBin) <> 0 Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПеременнуюСреды("PATH", ПеременнаяPATH + ";" + ПутьККаталогуBin, РасположениеПеременнойСреды.Пользователь);
	
КонецПроцедуры

Процедура ПроверитьНаличиеИспользуемойВерсии(Знач ИспользуемаяВерсия, Знач ВыполнятьУстановкуПриНеобходимости)
	
	КаталогУстановки = ПараметрыПриложения.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ИспользуемаяВерсия);
	Если ФС.КаталогСуществует(КаталогУстановкиВерсии) Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыполнятьУстановкуПриНеобходимости Тогда
		УстановщикOneScript = Новый УстановщикOneScript();
		УстановщикOneScript.УстановитьOneScript(ИспользуемаяВерсия);
	Иначе
		ВызватьИсключение СтрШаблон("Не обнаружена требуемая версия <%1>", ИспользуемаяВерсия);
	КонецЕсли;
	
КонецПроцедуры

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;
