///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <ОтключениеПолнотекстовогоПоиска>
//
///////////////////////////////////////////////////////////////////////////////

Перем ЗначениеПоиска;

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ОтключениеПолнотекстовогоПоиска";
	
КонецФункции // ИмяСценария()

// ПолучитьСтандартныеНастройкиСценария
//	Возвращает структуру настроек сценария
//
// Возвращаемое значение:
//   Структура   - Структура с настройками сценария
//  	* ИмяСценария	- Строка - Имя, с которым сохранятся настройки
//		* Настройка		- Соответствие - настройки
//
Функция ПолучитьСтандартныеНастройкиСценария() Экспорт
	
	НастройкиСценария	= Новый Соответствие;
	ПутьИРеквизиты		= Новый Соответствие;
	НастройкиСценария.Вставить("МетаданныеДляИсключения", ПутьИРеквизиты);
	
	Возврат Новый Структура("ИмяСценария, Настройка", ИмяСценария(), НастройкиСценария);
	
КонецФункции

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
	
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлОписанияМетаданных(АнализируемыйФайл) Тогда
		
		МассивРеквизитов = Неопределено;

		МетаданныеДляИсключения	= НастройкиСценария.Получить("МетаданныеДляИсключения");
		Если МетаданныеДляИсключения <> Неопределено Тогда
			ОтносительныйПуть = СтрЗаменить(АнализируемыйФайл.ПолноеИмя, ДополнительныеПараметры.КаталогРепозитория, "");
			Для Каждого Исключения Из МетаданныеДляИсключения Цикл
				НормализованныйПуть = ФайловыеОперации.НормализоватьРазделители(Исключения.Ключ);
				Если ОтносительныйПуть = НормализованныйПуть Тогда
					МассивРеквизитов = Исключения.Значение;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;

		Если МассивРеквизитов = Неопределено ИЛИ ЗначениеЗаполнено(МассивРеквизитов) Тогда
			//Неопределено - нет файла в исключении, массив не пустой - исключение только по реквизитам
			Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
			
			ЭтоEDT = ТипыФайлов.ЭтоФайлОписанияМетаданныхEDT(АнализируемыйФайл);
			
			Если ОтключитьПолнотекстовыйПоиск(АнализируемыйФайл.ПолноеИмя, МассивРеквизитов, ЭтоEDT) Тогда
				
				ДополнительныеПараметры.ИзмененныеКаталоги.Добавить(АнализируемыйФайл.ПолноеИмя);
				
			КонецЕсли;
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции // ОбработатьФайл()

Функция ОтключитьПолнотекстовыйПоиск(Знач ИмяФайла, МассивРеквизитов, ЭтоEDT)
	
	ТекстФайла			= ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	СодержимоеФайла		= ТекстФайла;
	
	Если Не ЗначениеЗаполнено(СодержимоеФайла) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(МассивРеквизитов) Тогда
		
		// получение текста файла до табличных частей
		Регексп = Новый РегулярноеВыражение("(<\?xml version[\w\W]+?)(<TabularSection|<\/MetaDataObject>|<\/mdclass:Document>)([\w\W]+)?");
		Регексп.ИгнорироватьРегистр = Истина;
		Регексп.Многострочный = Истина;
		Совпадения = Регексп.НайтиСовпадения(СодержимоеФайла);
		
		Если Совпадения.Количество() = 0 Тогда
			
			Возврат Ложь;
			
		КонецЕсли;
		
		СекцияДоТаблиц		= Совпадения[0].Группы[1].Значение;
		ЗакрывающаяСекция	= Совпадения[0].Группы[2].Значение;
		СекцияТаблиц		= Совпадения[0].Группы[3].Значение;
		
		СекцияДоТаблиц	= ОбработатьСтандартныеАтрибуты(СекцияДоТаблиц, МассивРеквизитов);
		СекцияДоТаблиц	= ОбработатьРеквизиты(СекцияДоТаблиц, МассивРеквизитов);
		
		ЕстьСекцияТаблиц = СекцияТаблиц <> "";
		
		Если ЕстьСекцияТаблиц Тогда
			
			ОбработатьТабличныеЧасти(СекцияТаблиц, МассивРеквизитов, ЭтоEDT);
			
		КонецЕсли;
		
		СодержимоеФайла = СекцияДоТаблиц + ?(ЕстьСекцияТаблиц, ЗакрывающаяСекция + СекцияТаблиц, ЗакрывающаяСекция);
		
	Иначе // Обработается весь файл целиком
		
		СодержимоеФайла = ЗаменитьПоиск(СодержимоеФайла);
		
	КонецЕсли;
	
	Если СтрСравнить(ТекстФайла, СодержимоеФайла) = 0 Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	ФайловыеОперации.ЗаписатьТекстФайла(ИмяФайла, СодержимоеФайла);
	
	Возврат Истина;
	
КонецФункции

Функция ЗаменитьПоиск(СодержимоеФайла, Знач ПоискРеквизита = "")
	
	ПолнотекстовыйПоиск = "(<(?:xr\:)?fullTextSearch>)(Use)(<\/(?:xr\:)?fullTextSearch>)";
	Выражение = ПоискРеквизита + ПолнотекстовыйПоиск;
	
	Регексп = Новый РегулярноеВыражение(Выражение);
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	ГруппыИндексов = Регексп.НайтиСовпадения(СодержимоеФайла);
	
	Если ГруппыИндексов.Количество() <> 0 Тогда
		
		Если ЗначениеЗаполнено(ПоискРеквизита) Тогда
			
			СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1$2DontUse$4");
			
		Иначе
			
			СодержимоеФайла = Регексп.Заменить(СодержимоеФайла, "$1DontUse$3");
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СодержимоеФайла;
	
КонецФункции

Функция ОбработатьСтандартныеАтрибуты(СодержимоеФайла, Исключения)
	
	СтандартныеАтрибуты = "Attribute name=""([а-яёa-zA-ZА-ЯЁ0-9_]+)"">[\w\W]+?((<xr:FullTextSearch>(Use)<\/xr:FullTextSearch>)|<\/xr:StandardAttribute>)";
	
	Регексп = Новый РегулярноеВыражение(СтандартныеАтрибуты);
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	КоллекцияСовпадений = Регексп.НайтиСовпадения(СодержимоеФайла);
	
	Для Каждого Совпадение Из КоллекцияСовпадений Цикл
		
		Если Совпадение.Группы[4].Значение = ЗначениеПоиска.Use И Исключения.Найти(Совпадение.Группы[1].Значение) = Неопределено Тогда
			
			ПоискРеквизита = СтрШаблон("(Attribute name=""%1"">[\w\W]+?)", Совпадение.Группы[1].Значение);
			СодержимоеФайла = ЗаменитьПоиск(СодержимоеФайла, ПоискРеквизита);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СодержимоеФайла;
	
КонецФункции

Функция ОбработатьРеквизиты(СодержимоеФайла, Исключения)
	
	ПоискРеквизиты = "<Name>([а-яёa-zA-ZА-ЯЁ0-9_]+)<\/Name>[\w\W]+?(<FullTextSearch>(Use)<\/FullTextSearch>)|<\/Properties>|<\/attributes>";
	
	Регексп = Новый РегулярноеВыражение(ПоискРеквизиты);
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	КоллекцияСовпадений = Регексп.НайтиСовпадения(СодержимоеФайла);
	
	Для Каждого Совпадение Из КоллекцияСовпадений Цикл
		
		Если Совпадение.Группы[3].Значение = ЗначениеПоиска.Use И Исключения.Найти(Совпадение.Группы[1].Значение) = Неопределено Тогда
			
			ПоискРеквизита = СтрШаблон("(<Name>%1<\/Name>[\w\W]+?)", Совпадение.Группы[1].Значение);
			СодержимоеФайла = ЗаменитьПоиск(СодержимоеФайла, ПоискРеквизита);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СодержимоеФайла;
	
КонецФункции

Функция ОбработатьТабличныеЧасти(ТекстФайла, Исключения, ЭтоEDT)
	
	Если ЭтоEDT Тогда
		
		Шаблон = "<\/producedTypes>\s+<name>([а-яёa-zA-ZА-ЯЁ0-9_]+)<\/name>|(<Name>)([а-яёa-zA-ZА-ЯЁ0-9_]+)<\/Name>|(<FullTextSearch>)(Use)<\/FullTextSearch>";
		ШаблонЗамены = "(<\/producedTypes>\s+<name>%1<\/name>[\w\W]+?<Name>%2<\/Name>[\w\W]+?)";
		
	Иначе
		
		Шаблон =  "TabularSection\.[\w\W]+?\.([\w\W]+?)""|(<Name>)([а-яёa-zA-ZА-ЯЁ0-9_]+)<\/Name>|(<FullTextSearch>)(Use)<\/FullTextSearch>";
		ШаблонЗамены = "(TabularSection\.[\w\W]+?\.%1""[\w\W]+?<Name>%2<\/Name>[\w\W]+?)";
		
	КонецЕсли;
	
	Регексп = Новый РегулярноеВыражение(Шаблон);
	Регексп.ИгнорироватьРегистр = Истина;
	Регексп.Многострочный = Истина;
	КоллекцияСовпадений = Регексп.НайтиСовпадения(ТекстФайла);
	
	Таблица		= "";
	Реквизит	= "";
	
	Для Каждого Совпадение Из КоллекцияСовпадений Цикл
		
		Таблица 	= ?(ЗначениеЗаполнено(Совпадение.Группы[1].Значение), Совпадение.Группы[1].Значение, Таблица);
		Реквизит	= ?(ЗначениеЗаполнено(Совпадение.Группы[3].Значение), Совпадение.Группы[3].Значение, Реквизит);
		ИспользованиеПоиска = Совпадение.Группы[4].Значение;
		
		Если ЗначениеЗаполнено(ИспользованиеПоиска) И Исключения.Найти(Таблица + "." + Реквизит) = Неопределено Тогда
			
			ПолнотекстовыйПоиск = СтрШаблон(ШаблонЗамены, Таблица, Реквизит);
			
			ТекстФайла = ЗаменитьПоиск(ТекстФайла, ПолнотекстовыйПоиск)
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТекстФайла;
	
КонецФункции

ЗначениеПоиска = Новый Структура ("Use, DontUse", "Use", "DontUse");
