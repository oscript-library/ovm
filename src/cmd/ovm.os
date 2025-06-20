#Использовать autumn
#Использовать autumn-logos
#Использовать autumn-cli

#Использовать "."
#Использовать "../core"

Функция НастройкиЛогоса()

	НастройкиЛога = Новый Соответствие;
	НастройкиЛога.Вставить("level", "INFO");
	НастройкиЛога.Вставить("appenders", "logos");
	НастройкиЛога.Вставить("classlayout", "РаскладкаЛогOVM");

	НастройкиУровнейЛогов = Новый Соответствие;
	НастройкиУровнейЛогов.Вставить("oscript.app.ovm", НастройкиЛога);

	НастройкаАппендера = Новый Соответствие;
	НастройкаАппендера.Вставить("type", "АппендерЛогOVM");
	НастройкаАппендера.Вставить("level", "INFO");

	НастройкиАппендеров = Новый Соответствие;

	НастройкиАппендеров.Вставить("logos", НастройкаАппендера);

	Результат = Новый Соответствие;

	Результат.Вставить("logos.logger", НастройкиУровнейЛогов);
	Результат.Вставить("logos.appender", НастройкиАппендеров);

	Возврат Результат;

КонецФункции

СоветДругогоМастера = Новый СоветДругогоМастера;
СоветДругогоМастера.ЗначенияДеталек(НастройкиЛогоса());

Поделка = Новый Поделка(СоветДругогоМастера);
Поделка.ЗапуститьПриложение();
