//////////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценария обработки файлов <СортировкаПравРолей>
//
//////////////////////////////////////////////////////////////////////////////////

#Область Переменные

// Глобальные переменные для хранения объектов регулярных выражений
Перем ВыражениеВсеОбъекты;
Перем ВыражениеМассивОбъектов;
Перем ВыражениеИмяОбъекта;
Перем ВыражениеПраваОбъекта;
Перем ВыражениеМассивПрав;
Перем ВыражениеЗначениеПрава;

#КонецОбласти

// Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//  Строка - Имя текущего сценария обработки файлов
Функция ИмяСценария() Экспорт
	Возврат "СортировкаПравРолей";
КонецФункции

// Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образовавшиеся в результате работы сценария
//											и которые необходимо дообработать
//
// Возвращаемое значение:
//  Булево - Признак выполненной обработки файла
//
// BSLLS:UnusedParameters-off API
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт 
// BSLLS:UnusedParameters-on
	ФайлОбработан = Ложь;
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлПравРоли(АнализируемыйФайл) Тогда
		НастройкиСценария = ДополнительныеПараметры.Настройки.Получить(ИмяСценария());
		ПолноеИмяФайла = АнализируемыйФайл.ПолноеИмя;
		ДополнительныеПараметры.Лог.Информация("Обработка файла '%1' по сценарию '%2'", ПолноеИмяФайла, ИмяСценария());

		ФайлОбработан = СортироватьПрава(ПолноеИмяФайла);
		Если ФайлОбработан Тогда
			ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(ПолноеИмяФайла);
		КонецЕсли;
	КонецЕсли;

	Возврат ФайлОбработан;
КонецФункции

Функция СортироватьПрава(ПолноеИмяФайла)
	ФайлИзменился = Ложь;
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ПолноеИмяФайла);

	Выражение = РегулярноеВыражениеВсеОбъекты();
	Совпадения = Выражение.НайтиСовпадения(СодержимоеФайла);
	Если Совпадения.Количество() > 0 Тогда
		Для Каждого Совпадение Из Совпадения Цикл
			ВсеОбъекты = Совпадение.Значение;
			СодержимоеФайла = СтрЗаменить(СодержимоеФайла, ВсеОбъекты, СтрокаЗаменыВсеОбъекты());

			ТаблицаОбъектов = СформироватьТаблицуОбъектов(ВсеОбъекты);
			Если ТаблицаОбъектов.Количество() > 0 Тогда
				СтрокаЗамены = ТаблицаОбъектовСтрокой(ТаблицаОбъектов);
				СодержимоеФайла = СтрЗаменить(СодержимоеФайла, СтрокаЗаменыВсеОбъекты(), СтрокаЗамены);
				ФайлИзменился = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Если ФайлИзменился Тогда
		ФайловыеОперации.ЗаписатьТекстФайла(ПолноеИмяФайла, СодержимоеФайла);
	КонецЕсли;

	Возврат Истина;
КонецФункции

Функция СформироватьТаблицуОбъектов(ВсеОбъекты)
	ТаблицаОбъектов = НоваяТаблицаОбъектов();
	МассивОбъектов = МассивОбъектовФайла(ВсеОбъекты);
	Для Каждого ЗаписьОбъекта Из МассивОбъектов Цикл
		ДобавитьЗаписьВТаблицуОбъектов(ТаблицаОбъектов, ЗаписьОбъекта);
	КонецЦикла;

	Возврат ТаблицаОбъектов;
КонецФункции

Функция МассивОбъектовФайла(ВсеОбъекты)
	Выражение = РегулярноеВыражениеМассивОбъектов();
	МассивОбъектов = Выражение.НайтиСовпадения(ВсеОбъекты);

	Результат = Новый Массив;
	Для Каждого ЗаписьОбъекта Из МассивОбъектов Цикл
		Результат.Добавить(ЗаписьОбъекта.Значение);
	КонецЦикла;

	Возврат Результат;
КонецФункции

Процедура ДобавитьЗаписьВТаблицуОбъектов(ТаблицаОбъектов, ТекстОбъекта)
	ОписаниеОбъекта = ОписаниеОбъекта(ТекстОбъекта);
	СтрокаОбъекта = ТаблицаОбъектов.Найти(ОписаниеОбъекта.Имя, "Имя");
	Если СтрокаОбъекта = Неопределено Тогда
		СтрокаОбъекта = ТаблицаОбъектов.Добавить();
		СтрокаОбъекта.Имя = ОписаниеОбъекта.Имя;
		СтрокаОбъекта.Объект = ОписаниеОбъекта.Объект;
		СтрокаОбъекта.Права = НоваяТаблицаПрав();
	КонецЕсли;

	Для Каждого СтрокаТЧ Из ОписаниеОбъекта.Права Цикл
		СтрокаПрава = СтрокаОбъекта.Права.Найти(СтрокаТЧ.Имя, "Имя");
		Если СтрокаПрава = Неопределено Тогда
			СтрокаПрава = СтрокаОбъекта.Права.Добавить();
			СтрокаПрава.Имя = СтрокаТЧ.Имя;
			СтрокаПрава.Текст = СтрокаТЧ.Текст;
		КонецЕсли;
		СтрокаПрава.Значение = СтрокаТЧ.Значение;
	КонецЦикла;
КонецПроцедуры

Функция ОписаниеОбъекта(ТекстОбъекта)
	Описание = Новый Структура("Имя, Объект, Права");
	Описание.Имя = ИмяОбъекта(ТекстОбъекта);

	ВсеПрава = ПраваОбъекта(ТекстОбъекта);
	Описание.Объект = СтрЗаменить(ТекстОбъекта, ВсеПрава, СтрокаЗаменыВсеПрава());

	Описание.Права = СформироватьТаблицуПрав(ВсеПрава);

	Возврат Описание;
КонецФункции

Функция СформироватьТаблицуПрав(ВсеПрава)
	ТаблицаПрав = НоваяТаблицаПрав();

	Выражение = РегулярноеВыражениеМассивПрав();
	Совпадения = Выражение.НайтиСовпадения(ВсеПрава);
	Для Каждого Совпадение Из Совпадения Цикл
		НоваяСтрока = ТаблицаПрав.Добавить();
		НоваяСтрока.Имя = ИмяОбъекта(Совпадение.Значение);
		НоваяСтрока.Значение = ЗначениеПрава(Совпадение.Значение);
		НоваяСтрока.Текст = ?(ПустаяСтрока(НоваяСтрока.Значение), Совпадение.Значение,
			ЗаменитьЗначениеПраваШаблоном(Совпадение.Значение, НоваяСтрока.Значение));
	КонецЦикла;

	Возврат ТаблицаПрав;
КонецФункции

Функция ТаблицаОбъектовСтрокой(ТаблицаОбъектов)
	МассивСтрок = Новый Массив;
	ТаблицаОбъектов.Сортировать("Имя");
	Для Каждого СтрокаТЧ Из ТаблицаОбъектов Цикл
		СтрокаТЧ.Права.Сортировать("Имя");

		МассивПрав = Новый Массив;
		Для Каждого СтрокаПрава Из СтрокаТЧ.Права Цикл
			Право = СтрЗаменить(СтрокаПрава.Текст, СтрокаЗаменыЗначение(), СтрокаПрава.Значение);
			МассивПрав.Добавить(Право);
		КонецЦикла;
		
		Если МассивПрав.Количество() > 0 Тогда
			СтрокаОбъекта = СтрЗаменить(СтрокаТЧ.Объект, СтрокаЗаменыВсеПрава(), СтрСоединить(МассивПрав, Символы.ПС));
			МассивСтрок.Добавить(СтрокаОбъекта);
		КонецЕсли;
	КонецЦикла;

	Возврат СтрСоединить(МассивСтрок, Символы.ПС);
КонецФункции

Функция ИмяОбъекта(Объект)
	Результат = "";

	Выражение = РегулярноеВыражениеИмяОбъекта();
	Совпадения = Выражение.НайтиСовпадения(Объект);
	Для Каждого Совпадение Из Совпадения Цикл
		Если Совпадение.Группы.Количество() > 1 Тогда
			Результат = Совпадение.Группы[1].Значение;
		КонецЕсли;

		Прервать;
	КонецЦикла;

	Возврат Результат;
КонецФункции

Функция ПраваОбъекта(Объект)
	Результат = "";

	Выражение = РегулярноеВыражениеПраваОбъекта();
	Совпадения = Выражение.НайтиСовпадения(Объект);
	Для Каждого Совпадение Из Совпадения Цикл
		Результат = Совпадение.Значение;
		Прервать;
	КонецЦикла;

	Возврат Результат;
КонецФункции

Функция ЗначениеПрава(Объект)
	Результат = "";

	Выражение = РегулярноеВыражениеЗначениеПрава();
	Совпадения = Выражение.НайтиСовпадения(Объект);
	Для Каждого Совпадение Из Совпадения Цикл
		Если Совпадение.Группы.Количество() > 1 Тогда
			Результат = Совпадение.Группы[1].Значение;
		КонецЕсли;

		Прервать;
	КонецЦикла;

	Возврат Результат;
КонецФункции

Функция ЗаменитьЗначениеПраваШаблоном(ТекстПрава, Значение)
	СтрокаПоиска = СтрШаблон("<value>%1</value>", Значение);
	СтрокаЗамены = СтрШаблон("<value>%1</value>", СтрокаЗаменыЗначение());

	Возврат СтрЗаменить(ТекстПрава, СтрокаПоиска, СтрокаЗамены);
КонецФункции

Функция РегулярноеВыражениеВсеОбъекты()
	Если ВыражениеВсеОбъекты = Неопределено Тогда
		ВыражениеВсеОбъекты = РегулярныеВыражения.Создать("\B.*<object>[\w\W]*</object>");
	КонецЕсли;

	Возврат ВыражениеВсеОбъекты;
КонецФункции

Функция РегулярноеВыражениеМассивОбъектов()
	Если ВыражениеМассивОбъектов = Неопределено Тогда
		ВыражениеМассивОбъектов = РегулярныеВыражения.Создать("\B.*<object>[\w\W]+?</object>");
	КонецЕсли;

	Возврат ВыражениеМассивОбъектов;
КонецФункции

Функция РегулярноеВыражениеИмяОбъекта()
	Если ВыражениеИмяОбъекта = Неопределено Тогда
		ВыражениеИмяОбъекта = РегулярныеВыражения.Создать("<name>([\w\.]+)</name>");
	КонецЕсли;

	Возврат ВыражениеИмяОбъекта;
КонецФункции

Функция РегулярноеВыражениеПраваОбъекта()
	Если ВыражениеПраваОбъекта = Неопределено Тогда
		ВыражениеПраваОбъекта = РегулярныеВыражения.Создать("\B.*<right>[\w\W]+</right>");
	КонецЕсли;

	Возврат ВыражениеПраваОбъекта;
КонецФункции

Функция РегулярноеВыражениеМассивПрав()
	Если ВыражениеМассивПрав = Неопределено Тогда
		ВыражениеМассивПрав = РегулярныеВыражения.Создать("\B.*<right>[\w\W]+?</right>");
	КонецЕсли;

	Возврат ВыражениеМассивПрав;
КонецФункции

Функция РегулярноеВыражениеЗначениеПрава()
	Если ВыражениеЗначениеПрава = Неопределено Тогда
		ВыражениеЗначениеПрава = РегулярныеВыражения.Создать("<value>([\w]+)</value>");
	КонецЕсли;

	Возврат ВыражениеЗначениеПрава;
КонецФункции

Функция СтрокаЗаменыВсеОбъекты()
	Возврат "<!-- ВсеОбъекты -->";
КонецФункции

Функция СтрокаЗаменыВсеПрава()
	Возврат "<!-- ВсеПрава -->";
КонецФункции

Функция СтрокаЗаменыЗначение()
	Возврат "<!-- Значение -->";
КонецФункции

Функция НоваяТаблицаОбъектов()
	ТаблицаОбъектов = Новый ТаблицаЗначений;
	ТаблицаОбъектов.Колонки.Добавить("Имя");
	ТаблицаОбъектов.Колонки.Добавить("Объект");
	ТаблицаОбъектов.Колонки.Добавить("Права");

	Возврат ТаблицаОбъектов;
КонецФункции

Функция НоваяТаблицаПрав()
	ТаблицаПрав = Новый ТаблицаЗначений;
	ТаблицаПрав.Колонки.Добавить("Имя");
	ТаблицаПрав.Колонки.Добавить("Значение");
	ТаблицаПрав.Колонки.Добавить("Текст");

	Возврат ТаблицаПрав;
КонецФункции
