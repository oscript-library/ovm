//////////////////////////////////////////////////////////////////////////
//
// LOGOS: вывод в консоль
//
//////////////////////////////////////////////////////////////////////////

Перем КартаСтатусовИУровней Экспорт;
Перем УстанавливаемыйСтатусСообщения Экспорт;

// Вывести сообщение через аппендер
//
// Параметры:
//   Сообщение - Строка - Выводимое сообщение
//   УровеньСообщения - Число - Числовое представление УровниЛога.
//
Процедура Вывести(Знач Сообщение, УровеньСообщения) Экспорт

	ПередаваемыйСтатусСообщения = ?(УстанавливаемыйСтатусСообщения = Неопределено,
		КартаСтатусовИУровней[УровеньСообщения],
		УстанавливаемыйСтатусСообщения
	);
	Сообщить(Сообщение, ПередаваемыйСтатусСообщения);

КонецПроцедуры

// Закрыть аппендер
//
Процедура Закрыть() Экспорт
	// NO-OP
КонецПроцедуры

// Устанавливает свойство аппендера, заданное в конфигурационном файле
//
// Параметры:
//   ИмяСвойства - Строка - Имя свойства
//   Значение - Произвольный - Значение свойства
//
Процедура УстановитьСвойство(Знач ИмяСвойства, Знач Значение) Экспорт
	Если ИмяСвойства = "message-status" Тогда
		УстанавливаемыйСтатусСообщения = Значение;
	КонецЕсли;
КонецПроцедуры // УстановитьСвойство()

&Желудь
Процедура ПриСозданииОбъекта()

	КартаСтатусовИУровней = Новый Соответствие;
	КартаСтатусовИУровней.Вставить(УровниЛога.Отладка, СтатусСообщения.БезСтатуса);
	КартаСтатусовИУровней.Вставить(УровниЛога.Информация, СтатусСообщения.Обычное);
	КартаСтатусовИУровней.Вставить(УровниЛога.Предупреждение, СтатусСообщения.Внимание);
	КартаСтатусовИУровней.Вставить(УровниЛога.Ошибка, СтатусСообщения.Важное);
	КартаСтатусовИУровней.Вставить(УровниЛога.КритичнаяОшибка, СтатусСообщения.ОченьВажное);

КонецПроцедуры
