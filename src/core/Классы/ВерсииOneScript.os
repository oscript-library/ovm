#Использовать 1commands
#Использовать fluent
#Использовать fs
#Использовать collectionos

&ЛогOVM
Перем Лог;

&Пластилин
Перем ПараметрыOVM;

Перем ЭтоWindows;
Перем ДопустимыеАлиасы; // Кеш коллекции допустимых алиасов

&Желудь
Процедура ПриСозданииОбъекта()
КонецПроцедуры

Функция ДопустимыеАлиасы() Экспорт

	Если ДопустимыеАлиасы = Неопределено Тогда

		ДопустимыеАлиасы = Новый КартаСоответствие;

		ДопустимыеАлиасы.Вставить("lts",    Версия("lts", Ложь));
		ДопустимыеАлиасы.Вставить("stable", Версия("latest", Ложь));
		ДопустимыеАлиасы.Вставить("dev",    Версия("latest-dev", Ложь));

		ДопустимыеАлиасы.Вставить("preview",     Версия("preview", Истина));
		ДопустимыеАлиасы.Вставить("preview-dev", Версия("night-build", Истина));

	КонецЕсли;

	Возврат ДопустимыеАлиасы;

КонецФункции

Функция Версия(Метка, ЭтоВерсия2)

	Результат = Новый Структура;

	Результат.Вставить("Метка", Метка);
	Результат.Вставить("ЭтоВерсия2", ЭтоВерсия2);

	Возврат Результат;

КонецФункции

// Проверить, что версия установлена
//
// Параметры:
//   ПроверяемаяВерсия - Строка - Алиас версии
//
//  Возвращаемое значение:
//   Булево - Версия установлена
//
Функция ВерсияУстановлена(Знач ПроверяемаяВерсия) Экспорт

	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ПроверяемаяВерсия);

	СуществуетКаталогУстановкиВерсии = ФС.КаталогСуществует(КаталогУстановкиВерсии);
	СуществуетИсполняемыйФайл =
		ФС.ФайлСуществует(ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript.exe")) // SCD
		Или ФС.ФайлСуществует(ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript")) // SCD
		Или ФС.ФайлСуществует(ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript.bat")) // FDD
		Или ФС.ФайлСуществует(ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript.sh")); // FDD
		
	Результат = СуществуетКаталогУстановкиВерсии И СуществуетИсполняемыйФайл;

	Лог.Отладка("Версия %1 установлена: %2", ПроверяемаяВерсия, Результат);
	Возврат Результат;

КонецФункции

// Проверить, что переданная версия является текущей (активированной)
//
// Параметры:
//   ПроверяемаяВерсия - Строка - Алиас
//
//  Возвращаемое значение:
//   Булево - Это текущая версия
//
Функция ЭтоТекущаяВерсия(Знач ПроверяемаяВерсия) Экспорт

	Если ПроверяемаяВерсия = "current" Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если НЕ ВерсияУстановлена("current") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ ВерсияУстановлена(ПроверяемаяВерсия) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	АлиасыСимлинков = ПолучитьАлиасыСимлинков();
	
	ТекущаяВерсия = АлиасыСимлинков["current"];

	Возврат ПроверяемаяВерсия = ТекущаяВерсия;

КонецФункции

// Получает путь к исполняемому файлу OneScript
//
// Параметры:
//   КаталогУстановкиВерсии - Строка - Путь к конкретной версии.
//
//  Возвращаемое значение:
//   Строка - Путь к исполняемому файлу.
//
Функция ПутьКИсполняемомуФайлу(КаталогУстановкиВерсии) Экспорт

	ПутьКИсполняемомуФайлу = ОбъединитьПути(КаталогУстановкиВерсии, "bin", "oscript");
	
	Если ЭтоWindows И ФС.ФайлСуществует(ПутьКИсполняемомуФайлу + ".exe") Тогда
		ПутьКИсполняемомуФайлу = ПутьКИсполняемомуФайлу + ".exe";
	ИначеЕсли ЭтоWindows Тогда
		ПутьКИсполняемомуФайлу = ПутьКИсполняемомуФайлу + ".bat";
	ИначеЕсли ФС.ФайлСуществует(ПутьКИсполняемомуФайлу + ".sh") Тогда
		ПутьКИсполняемомуФайлу = ПутьКИсполняемомуФайлу + ".sh";
	КонецЕсли; // BSLLS:IfElseIfEndsWithElse-off

	Возврат ПутьКИсполняемомуФайлу;

КонецФункции

// Получить информацию об установленных версиях
//
//  Возвращаемое значение:
//   ТаблицаЗначений - Информация об установленных версиях:
//		* Алиас - Строка - Алиас версии (имя каталога)
//		* Путь - Строка - Полный путь к каталогу версии
//		* Версия - Строка - Точная версия OneScript
//		* ЭтоСимлинк - Булево - Каталог является символической ссылкой
//
Функция ПолучитьСписокУстановленныхВерсий() Экспорт
	
	УстановленныеВерсии = Новый ТаблицаЗначений;
	УстановленныеВерсии.Колонки.Добавить("Алиас");
	УстановленныеВерсии.Колонки.Добавить("Путь");
	УстановленныеВерсии.Колонки.Добавить("Версия");
	УстановленныеВерсии.Колонки.Добавить("ЭтоСимлинк");
	
	АлиасыСимлинков = ПолучитьАлиасыСимлинков();
	
	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	НайденныеФайлы = НайтиФайлы(КаталогУстановки, ПолучитьМаскуВсеФайлы());
	Для Каждого НайденныйФайл Из НайденныеФайлы Цикл
		Если НЕ ВерсияУстановлена(НайденныйФайл.Имя) Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаВерсии = УстановленныеВерсии.Добавить();
		СтрокаВерсии.Алиас = НайденныйФайл.Имя;
		СтрокаВерсии.Путь = НайденныйФайл.ПолноеИмя;
		СтрокаВерсии.Версия = ПолучитьТочнуюВерсиюOneScript(СтрокаВерсии.Алиас);
		СтрокаВерсии.ЭтоСимлинк = АлиасыСимлинков.Получить(НайденныйФайл.Имя) <> Неопределено;

	КонецЦикла;
	
	Возврат УстановленныеВерсии;
	
КонецФункции

Функция ПолучитьАлиасыСимлинков()
	
	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	
	Команда = Новый Команда();
		
	Если ЭтоWindows Тогда
		Команда.УстановитьКоманду("dir");
	Иначе
		Команда.УстановитьКоманду("ls");
		Команда.ДобавитьПараметр("-la");
	КонецЕсли;
	Команда.ДобавитьПараметр(КаталогУстановки);
	
	Команда.Исполнить();
	
	ВыводКоманды = Команда.ПолучитьВывод();

	Если ЭтоWindows Тогда
		Выражение = "(<JUNCTION>|<SYMLINKD>)\s*(.+?)\s*\[(.+)\]";
	Иначе
		Выражение = "l.+?(\d\d:\d\d)\s*(.+?)\s*->\s*(.+)";
	КонецЕсли;
	
	РВ = Новый РегулярноеВыражение(Выражение);
	РВ.МногоСтрочный = Ложь;
	Совпадения = РВ.НайтиСовпадения(ВыводКоманды);
	
	АлиасыСимлинков = Новый Соответствие;
	РазделительПути = ПолучитьРазделительПути();
	
	Для Каждого Совпадение Из Совпадения Цикл
		Группы = Совпадение.Группы;
		ЧастиПути = СтрРазделить(Группы[3].Значение, РазделительПути);
		АлиасыСимлинков.Вставить(Группы[2].Значение, ЧастиПути[ЧастиПути.ВГраница()]);
	КонецЦикла;
	
	Возврат АлиасыСимлинков;
	
КонецФункции

// Получить информацию о версиях, доступных к установке
//
//  Возвращаемое значение:
//   ТаблицаЗначений - Информация об установленных версиях:
//		* Алиас - Строка - Алиас версии (имя каталога)
//		* Путь - Строка - Полный путь к каталогу версии
//
Функция ПолучитьСписокДоступныхКУстановкеВерсий() Экспорт
	
	ДоступныеВерсии = Новый ТаблицаЗначений;
	ДоступныеВерсии.Колонки.Добавить("Алиас");
	ДоступныеВерсии.Колонки.Добавить("Путь");
	
	АдресСайтаОСкрипт = ПараметрыOVM.АдресСайтаОСкрипт();
	
	Таймаут = 10;
	Соединение = Новый HTTPСоединение(
		АдресСайтаОСкрипт,
		,
		,
		,
		,
		Таймаут
	);
	Запрос = Новый HTTPЗапрос("downloads");
	
	Ответ = Соединение.Получить(Запрос);
	HTTP_OK = 200;
	Если Ответ.КодСостояния <> HTTP_OK Тогда
		ВызватьИсключение Ответ.КодСостояния;
	КонецЕсли;
	
	ТелоСтраницы = Ответ.ПолучитьТелоКакСтроку();
	
	РегулярноеВыражение = Новый РегулярноеВыражение("<a href=""(\/downloads\/[^""]+)"">(\d+\.\d+\.\d+(\.\d+)?)");
	ИндексГруппыАдрес = 1;
	ИндексГруппыВерсия = 2;

	Совпадения = РегулярноеВыражение.НайтиСовпадения(ТелоСтраницы);
	Для Каждого СовпадениеРегулярногоВыражения Из Совпадения Цикл
		ГруппаАдрес = СовпадениеРегулярногоВыражения.Группы[ИндексГруппыАдрес];
		ГруппаВерсия = СовпадениеРегулярногоВыражения.Группы[ИндексГруппыВерсия];
		
		// TODO: Убрать после решения https://github.com/EvilBeaver/OneScript/issues/667
		Если ГруппаВерсия.Значение = "1.0.9" Тогда
			Продолжить;
		КонецЕсли;

		ДоступнаяВерсия = ДоступныеВерсии.Добавить();
		ДоступнаяВерсия.Алиас = ГруппаВерсия.Значение;
		ДоступнаяВерсия.Путь = АдресСайтаОСкрипт + ГруппаАдрес.Значение;
	КонецЦикла;

	Итератор = ДопустимыеАлиасы().Ключи().Итератор();

	Пока Итератор.ЕстьСледующий() Цикл
		ОбеспечитьСтрокуВерсииПоАлиасу(ДоступныеВерсии, Итератор.Следующий(), "Путь");
	КонецЦикла;

	Возврат ДоступныеВерсии;

КонецФункции

// <Описание функции>
//
//  Возвращаемое значение:
//   ТаблицаЗначений - Информация об установленных версиях:
//		* Алиас - Строка - Алиас версии (имя каталога)
//		* ПутьЛокальный - Строка - Полный путь к каталогу версии
//		* ПутьСервер - Строка - Полный путь к каталогу версии на сайте OneScript
//		* Версия - Строка - Точная версия OneScript (только для установленных версий)
//		* ЭтоСимлинк - Булево - Каталог является символической ссылкой
//		* ВерсияУстановлена - Булево - Установлена ли текущая версия
//
Функция ПолучитьСписокВсехВерсий() Экспорт

	СписокУстановленныхВерсий = ПолучитьСписокУстановленныхВерсий();
	СписокДоступныхВерсий = ПолучитьСписокДоступныхКУстановкеВерсий();

	ВсеВерсии = Новый ТаблицаЗначений;
	ВсеВерсии.Колонки.Добавить("Алиас", Новый ОписаниеТипов("Строка"));
	ВсеВерсии.Колонки.Добавить("Версия", Новый ОписаниеТипов("Строка"));
	ВсеВерсии.Колонки.Добавить("ПутьЛокальный", Новый ОписаниеТипов("Строка"));
	ВсеВерсии.Колонки.Добавить("ПутьСервер", Новый ОписаниеТипов("Строка"));
	ВсеВерсии.Колонки.Добавить("ЭтоСимлинк", Новый ОписаниеТипов("Булево"));
	ВсеВерсии.Колонки.Добавить("ВерсияУстановлена", Новый ОписаниеТипов("Булево"));

	Для Каждого ДоступнаяВерсия Из СписокДоступныхВерсий Цикл		
		СтрокаВсеВерсии = ВсеВерсии.Найти(ДоступнаяВерсия.Алиас, "Алиас");
		Если СтрокаВсеВерсии = Неопределено Тогда
			СтрокаВсеВерсии = ВсеВерсии.Добавить();
			СтрокаВсеВерсии.Алиас = ДоступнаяВерсия.Алиас;
			СтрокаВсеВерсии.ЭтоСимлинк = Ложь;	
		КонецЕсли;
		
		СтрокаВсеВерсии.ПутьСервер = ДоступнаяВерсия.Путь;
	КонецЦикла;

	Для Каждого УстановленнаяВерсия Из СписокУстановленныхВерсий Цикл
		СтрокаВсеВерсии = ВсеВерсии.Найти(УстановленнаяВерсия.Алиас, "Алиас");
		Если СтрокаВсеВерсии = Неопределено Тогда
			СтрокаВсеВерсии = ВсеВерсии.Добавить();
			СтрокаВсеВерсии.Алиас = УстановленнаяВерсия.Алиас;
			СтрокаВсеВерсии.ЭтоСимлинк = УстановленнаяВерсия.ЭтоСимлинк;
		КонецЕсли;

		СтрокаВсеВерсии.Версия = УстановленнаяВерсия.Версия;
		СтрокаВсеВерсии.ПутьЛокальный = УстановленнаяВерсия.Путь;
		СтрокаВсеВерсии.ВерсияУстановлена = Истина;
	КонецЦикла;

	Итератор = ДопустимыеАлиасы().Ключи().Итератор();

	Пока Итератор.ЕстьСледующий() Цикл
		ОбеспечитьСтрокуВерсииПоАлиасу(ВсеВерсии, Итератор.Следующий());
	КонецЦикла;

	ВсеВерсии.Сортировать("Алиас");

	Возврат ВсеВерсии;

КонецФункции

// Получить полный путь к исполняемому файлу OneScript (файлу oscript.exe|oscript.bat|oscript)
//
// Параметры:
//   УстановленнаяВерсия - Строка - Алиас проверяемой версии
//
//  Возвращаемое значение:
//  Строка - Полный путь к исполняемому файлу oscript
//
Функция ПолучитьПутьКУстановленномуДвижкуOneScript(Знач УстановленнаяВерсия) Экспорт
	
	УстановленныеВерсии = ПолучитьСписокУстановленныхВерсий();
	
	ПутьКУстановленнойВерсии = ПроцессорыКоллекций.ИзКоллекции(УстановленныеВерсии)
		.Фильтровать(
			"(Элемент) -> Элемент.Алиас = УстановленнаяВерсия",
			Новый Структура("УстановленнаяВерсия", УстановленнаяВерсия)
		)
		.Первые(1)
		.Обработать("(Элемент) -> ПутьКИсполняемомуФайлу(Элемент.Путь);", ЭтотОбъект)
		.ПолучитьПервый();
	
	Возврат ПутьКУстановленнойВерсии;
	
КонецФункции

Процедура ОбеспечитьСтрокуВерсииПоАлиасу(ТаблицаВерсий, Алиас, ИмяРеквизитаПуть = "ПутьСервер")
	
	СтрокаВерсии = ТаблицаВерсий.Найти(Алиас, "Алиас"); 

	Если СтрокаВерсии = Неопределено Тогда
		СтрокаВерсии = ТаблицаВерсий.Добавить();
		СтрокаВерсии.Алиас = Алиас;
	КонецЕсли;

	СтрокаВерсии[ИмяРеквизитаПуть] = ПараметрыOVM.ПолныйАдресККаталогуДистрибутивов();

КонецПроцедуры

Функция ПолучитьТочнуюВерсиюOneScript(Знач ПроверяемаяВерсия)

	КаталогУстановки = ПараметрыOVM.КаталогУстановкиПоУмолчанию();
	КаталогУстановкиВерсии = ОбъединитьПути(КаталогУстановки, ПроверяемаяВерсия);
	ПутьКИсполняемомуФайлу = ПутьКИсполняемомуФайлу(КаталогУстановкиВерсии);

	Команда = Новый Команда();
	Команда.УстановитьКоманду(ПутьКИсполняемомуФайлу);
	Команда.ДобавитьПараметр("-version");
	
	Команда.Исполнить();
	
	ВыводКоманды = СокрЛП(Команда.ПолучитьВывод());
	Если СтрЧислоСтрок(ВыводКоманды) > 1 Тогда
		РегулярноеВыражение = Новый РегулярноеВыражение("Version (\d+\.\d+\.\d+\.\d+)");
		Совпадения = РегулярноеВыражение.НайтиСовпадения(ВыводКоманды);
		Если Совпадения.Количество() = 1 Тогда
			ВыводКоманды = Совпадения[0].Группы[1].Значение;
		Иначе
			ВыводКоманды = "unknown";
		КонецЕсли;
	КонецЕсли;

	Возврат ВыводКоманды;
	
КонецФункции

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;
