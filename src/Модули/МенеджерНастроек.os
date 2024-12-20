Перем ЛокальныеНастройки;
Перем ГлобальныеНастройки;
Перем ИспользуютсяЛокальныеНастройки;

Перем КаталогРепозитория;
Перем НастройкиИнициализированы;
Перем КаталогГлобальныхНастроек;

///////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////

Функция Настройки() Экспорт
	
	Если НЕ НастройкиИнициализированы Тогда
		
		ВызватьИсключение "Настройки не загружены";
		
	КонецЕсли;
	
	Если ИспользуютсяЛокальныеНастройки() Тогда
		
		Возврат ЛокальныеНастройки;
		
	Иначе
		
		Возврат ГлобальныеНастройки;
		
	КонецЕсли;
	
КонецФункции

Функция НастройкиРепозитория(ПутьКаталогаРепозитория, ВернутьГлобальныеЕслиНетЛокальных = Истина) Экспорт
	
	КаталогРепозитория = ПутьКаталогаРепозитория;
	
	Если ВернутьГлобальныеЕслиНетЛокальных Тогда
		
		ГлобальныеНастройки();
		
	КонецЕсли;
	
	Лог = МенеджерПриложения.ПолучитьЛог();
	
	ЛокальныеНастройки = Новый НастройкиРепозитория(КаталогРепозитория);
	
	ИспользуютсяЛокальныеНастройки = ЕстьНастройкиPrecommt4onec(ЛокальныеНастройки) ИЛИ НЕ ВернутьГлобальныеЕслиНетЛокальных;
	
	Если ИспользуютсяЛокальныеНастройки Тогда
		
		ВозвращаемаяНастройка = ЛокальныеНастройки;
		Лог.Информация("Используем локальные настройки");
		
	Иначе
		
		ВозвращаемаяНастройка = ГлобальныеНастройки;
		
		Лог.Информация("Используем глобальные настройки");
		
		Если НЕ ЕстьНастройкиPrecommt4onec(ГлобальныеНастройки) Тогда
			
			Лог.Предупреждение("Файл глобальных настроек '%1' не содержит настройки прекоммита", МенеджерПриложения.ПутьКРодительскомуКаталогу());
			
		КонецЕсли;
		
	КонецЕсли;
	
	НастройкиИнициализированы = Истина;
	
	ПроверитьНастройкуПроектов();
	
	Возврат ВозвращаемаяНастройка;
	
КонецФункции

Функция ГлобальныеНастройки() Экспорт
	
	Если ГлобальныеНастройки = Неопределено Тогда
		
		Если НЕ ЗначениеЗаполнено(КаталогГлобальныхНастроек) Тогда
			ГлобальныеНастройки = Новый НастройкиРепозитория(МенеджерПриложения.ПутьКРодительскомуКаталогу());
		Иначе
			ГлобальныеНастройки = Новый НастройкиРепозитория(КаталогГлобальныхНастроек);
		КонецЕсли;
		
	КонецЕсли;
	
	НастройкиИнициализированы = Истина;
	
	Возврат ГлобальныеНастройки;
	
КонецФункции

Функция ЗначениеНастройки(КлючНастройки, Подпроект = Неопределено, ЗначениеПоУмолчанию = Неопределено) Экспорт
	
	Значение = ЗначениеНастроекПоКлючу(Настройки(), КлючНастройки(Подпроект, КлючНастройки));
	
	Возврат ?(Значение = Неопределено, ЗначениеПоУмолчанию, Значение);
	
КонецФункции

Функция ИменаЗагружаемыхСценариев(Подпроект = "") Экспорт
	
	ИменаИсключаемыхСценариев = ЗначениеНастройки("ОтключенныеСценарии", Подпроект);
	
	ГлобальныеСценарии = ЗначениеНастройки("ГлобальныеСценарии", Подпроект);
	
	Если ГлобальныеСценарии = Неопределено Тогда
		
		ГлобальныеСценарии = ПолучитьЗначениеНастройки(ГлобальныеНастройки(), "ГлобальныеСценарии");
		
	КонецЕсли;
	
	ИменаЗагружаемыхСценариев = Новый Массив;
	
	Если ИменаИсключаемыхСценариев = Неопределено Тогда
		
		ИменаИсключаемыхСценариев = Новый Массив();
		
	КонецЕсли;
	
	Для Каждого ИмяСценария Из ГлобальныеСценарии Цикл
		
		Если ИменаИсключаемыхСценариев.Найти(ИмяСценария) = Неопределено Тогда
			
			ИменаЗагружаемыхСценариев.Добавить(ИмяСценария);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИменаЗагружаемыхСценариев;
	
КонецФункции

Функция ПолучитьСписокИсполняемыхСценариев(Знач ГлобальныеСценарии, Знач ОтключенныеСценарии) Экспорт
	
	ИменаЗагружаемыхСценариев = Новый Массив;
	
	Если ОтключенныеСценарии = Неопределено Тогда
		
		ОтключенныеСценарии = Новый Массив();
		
	КонецЕсли;
	
	Для Каждого ИмяСценария Из ГлобальныеСценарии Цикл
		
		Если ОтключенныеСценарии.Найти(ИмяСценария) = Неопределено Тогда
			
			ИменаЗагружаемыхСценариев.Добавить(ИмяСценария);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИменаЗагружаемыхСценариев;
	
КонецФункции

Функция ИспользуютсяЛокальныеНастройки() Экспорт
	
	Возврат ИспользуютсяЛокальныеНастройки = Истина;
	
КонецФункции

#Область Проекты

Функция ПроектыКонфигурации() Экспорт
	
	Проекты = Новый Массив;
	
	БлокПроекты = ЗначениеНастройки(КлючПроекты());
	
	Если ЗначениеЗаполнено(БлокПроекты) Тогда
		
		Для Каждого Элемент Из БлокПроекты Цикл
			
			Проекты.Добавить(Элемент.Ключ);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Проекты;
	
КонецФункции

Функция НастройкиПроекта(Подпроект = "") Экспорт
	
	Значение = ПолучитьНастройкиПроекта(Настройки(), Подпроект);
	
	Возврат Значение;
	
КонецФункции

Функция НастройкаДляФайла(Знач ОтносительноеИмяФайла) Экспорт
	
	Возврат НастройкиПроекта(ИмяПроектаДляФайла(ОтносительноеИмяФайла));
	
КонецФункции

Функция ИмяПроектаДляФайла(Знач ОтносительноеИмяФайла) Экспорт
	
	Если СтрНачинаетсяС(ОтносительноеИмяФайла, "/") ИЛИ СтрНачинаетсяС(ОтносительноеИмяФайла, "\") Тогда
		
		ОтносительноеИмяФайла = Сред(ОтносительноеИмяФайла, 2);
		
	КонецЕсли;
	
	ОтносительноеИмяФайла = НРег(ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, ОтносительноеИмяФайла));
	
	Для Каждого ИмяПроекта Из ПроектыКонфигурации() Цикл
		
		НормализованноеИмяПроекта = НРег(ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, ИмяПроекта));
		
		Если СтрНачинаетсяС(ОтносительноеИмяФайла, НормализованноеИмяПроекта) Тогда
			
			Возврат ИмяПроекта;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Процедура УдалитьПроекты() Экспорт
	
	ЗначениеНастройки("").Удалить(КлючПроекты()); // Удаляем ветку "Проекты" из корня настроек прекоммит
	
КонецПроцедуры

Процедура УдалитьПроект(Подпроект) Экспорт
	
	ИмяПроекта = ИмяПроектаДляФайла(Подпроект);
	
	Если НЕ ЗначениеЗаполнено(ИмяПроекта) ИЛИ СтрДлина(ИмяПроекта) <> СтрДлина(Подпроект) Тогда
		МенеджерПриложения.ПолучитьЛог().Предупреждение("Не найден проект %1", Подпроект);
		Возврат;
	КонецЕсли;
	
	ЗначениеНастройки(КлючПроекты()).Удалить(ИмяПроекта);
	
КонецПроцедуры

Функция НормализованноеИмяПроекта(ИмяПроекта) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИмяПроекта) Тогда
		
		Возврат ИмяПроекта;
		
	КонецЕсли;
	
	НормализованноеИмяПроекта = ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория, ИмяПроекта);
	
	Возврат НормализованноеИмяПроекта;
	
КонецФункции

Функция ПроверитьНастройкуПроектов() Экспорт
	
	Успешно = Истина;
	
	Лог = МенеджерПриложения.ПолучитьЛог();
	Для Каждого ИмяПроекта Из ПроектыКонфигурации() Цикл
		
		Если НормализованноеИмяПроекта(ИмяПроекта) <> ИмяПроекта Тогда
			
			Лог.Предупреждение("Имя проекта '%1' указано не корректно (должно быть %2), возможно приложение будет работать не корректно", ИмяПроекта, НормализованноеИмяПроекта(ИмяПроекта));
			Успешно = Ложь;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Успешно;
	
КонецФункции

#КонецОбласти

Функция ЭтоНовый() Экспорт
	
	Если НЕ НастройкиИнициализированы Тогда
		Возврат Истина;
	Иначе
		Возврат Настройки().ЭтоНовый();
	КонецЕсли;
	
КонецФункции

Процедура ЗаписатьНастройки() Экспорт
	
	Настройки().ЗаписатьНастройкиПриложения(КлючНастройкиPrecommit(), ЗначениеНастройки(""));
	
КонецПроцедуры

Процедура УдалитьНастройки() Экспорт
	
	Если НЕ ИспользуютсяЛокальныеНастройки() Тогда
		
		ВызватьИсключение "Нельзя удалять глобальную настройку";
		
	КонецЕсли;
	
	Настройки().УдалитьНастройкиПриложения(КлючНастройкиPrecommit());
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ФУНКЦИОНАЛ
///////////////////////////////////////////////////////////////////

Функция КлючНастройкиPrecommit() Экспорт
	
	Возврат "Precommt4onecСценарии";
	
КонецФункции

Функция КлючПроекты() Экспорт
	
	Возврат "Проекты";
	
КонецФункции

Функция ПолучитьИменаСценариевКаталога(КаталогСценариев) Экспорт
	
	НайденныеСценарии = Новый Массив;
	ФайлыСценариев = НайтиФайлы(КаталогСценариев, "*.os");
	Для Каждого ФайлСценария Из ФайлыСценариев Цикл
		
		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		НайденныеСценарии.Добавить(ФайлСценария.Имя);
		
	КонецЦикла;
	
	Возврат НайденныеСценарии;
	
КонецФункции

Функция КлючНастройки(Знач Проект = Неопределено, КлючНастройки = Неопределено)
	
	Ключ = Новый Массив();
	
	Если ЗначениеЗаполнено(Проект) И ЕстьПроект(Проект) Тогда
		
		Ключ.Добавить(КлючПроекты());
		Ключ.Добавить(Проект);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КлючНастройки) Тогда
		
		Ключ.Добавить(КлючНастройки);
		
	КонецЕсли;
	
	Возврат Ключ;
	
КонецФункции

Функция ЕстьПроект(Проект)
	
	Возврат ПроектыКонфигурации().Найти(Проект) <> Неопределено;
	
КонецФункции

Функция ПолучитьНастройкиПроекта(Настройка, Подпроект) Экспорт
	
	Значение = ЗначениеНастроекПоКлючу(Настройка, КлючНастройки(Подпроект));
	
	Если Значение = Неопределено Тогда
		
		Значение = ЗначениеНастроекПоКлючу(Настройка, "");
		
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции

Функция ЗначениеНастроекПоКлючу(Настройка, КлючНастройки)
	
	Значение = Настройка.НастройкиПриложения(КлючНастройкиPrecommit());
	
	Возврат ЗначениеПоКлючу(Значение, КлючНастройки);
	
КонецФункции

Функция ЗначениеПоКлючу(Коллекция, КлючЗначения) Экспорт
	
	Значение = Коллекция;
	
	Если НЕ ЗначениеЗаполнено(КлючЗначения) Тогда
		
		Возврат Значение;
		
	ИначеЕсли ТипЗнч(КлючЗначения) = Тип("Строка") Тогда
		
		Ключи = СтрРазделить(КлючЗначения, ".");
		
	Иначе
		
		Ключи = КлючЗначения;
		
	КонецЕсли;
	
	Для Каждого Ключ Из Ключи Цикл
		
		Значение = Значение.Получить(Ключ);
		
		Если Значение = Неопределено Тогда
			
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Значение;
	
КонецФункции

Функция ЕстьНастройкиPrecommt4onec(Настройка)
	
	Возврат НЕ Настройка.ЭтоНовый() И ЗначениеНастроекПоКлючу(Настройка, "").Количество();
	
КонецФункции

Функция ПолучитьЗначениеНастройки(Настройка, КлючНастройки, Подпроект = Неопределено)
	
	Значение = ЗначениеНастроекПоКлючу(Настройка, КлючНастройки(Подпроект, КлючНастройки));
	
	Возврат Значение;
	
КонецФункции

Процедура УстановитьКаталогГлобальныхНастроек(Каталог) Экспорт
	
	КаталогГлобальныхНастроек = Каталог;
	
КонецПроцедуры

Процедура СбросСостоянияМенеджера() Экспорт
	
	ЛокальныеНастройки = Неопределено;
	ГлобальныеНастройки = Неопределено;
	ИспользуютсяЛокальныеНастройки = Ложь;
	
	НастройкиИнициализированы = Ложь;
	КаталогГлобальныхНастроек = Неопределено;
	КаталогРепозитория = Неопределено;
	
КонецПроцедуры

СбросСостоянияМенеджера();
