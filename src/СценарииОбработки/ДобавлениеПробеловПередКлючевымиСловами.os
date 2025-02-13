///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов 
//	<ДобавлениеПробеловПередКлючевымиСловами>
//
///////////////////////////////////////////////////////////////////////////////

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ДобавлениеПробеловПередКлючевымиСловами";

КонецФункции // ИмяСценария()

// ОбработатьФайл
//	Выполняет обработку файла
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
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.Настройки.Получить(ИмяСценария());
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл)
			И НЕ ТипыФайлов.ЭтоМодульРасширенияСКонтролемИзменений(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		Если ВставитьНужныеПробелы(АнализируемыйФайл.ПолноеИмя) Тогда

			ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);

		КонецЕсли;

		Возврат Истина;
		
	КонецЕсли;
	
	Возврат ЛОЖЬ;

КонецФункции // ОбработатьФайл()

Функция ВставитьНужныеПробелы(Знач ИмяФайла)

	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);

	Если Не ЗначениеЗаполнено(СодержимоеФайла) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Регексп = Новый РегулярноеВыражение("(^[^\n\/]*\))(Экспорт)([\s]*?)([\/\/]+[^\n]*?)*?$");
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	ГруппыИндексов = Регексп.НайтиСовпадения(СодержимоеФайла);
	Если ГруппыИндексов.Количество() = 0 Тогда

		Возврат ЛОЖЬ;

	КонецЕсли;
	
	СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1 $2$3$4");
	ФайловыеОперации.ЗаписатьТекстФайла(ИмяФайла, СодержимоеФайла);

	Возврат Истина;

КонецФункции
