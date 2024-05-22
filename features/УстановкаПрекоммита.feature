# language: ru

Функциональность: Установка прекоммита

Как разработчик
Я хочу иметь возможность устанавкливать precommit4onec в мой репозиторий
Чтобы автоматически выполять обработку исходников перед фиксацией изменений в репозитории

Контекст:
	Допустим Я очищаю параметры команды "oscript" в контексте 
		И я включаю отладку лога с именем "oscript.app.precommit4onec"
		И я создаю временный каталог и запоминаю его как "КаталогРепозиториев"
		И я переключаюсь во временный каталог "КаталогРепозиториев"
		И я создаю новый репозиторий "rep1" в каталоге "КаталогРепозиториев" и запоминаю его как "Репозиторий1"
		И я создаю новый репозиторий "rep2" в каталоге "КаталогРепозиториев" и запоминаю его как "Репозиторий2"

Сценарий: Установка precommit4onec в репозиторий
	Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install rep1"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "precommit4onec v24.05"
		И Вывод команды "oscript" содержит "Pre-commit hook для rep1 создан"
		И В каталоге ".git/hooks" репозитория "Репозиторий1" есть файл "pre-commit"

Сценарий: precommit4onec не устанавливается в пустой каталог
	Когда я создаю временный каталог и запоминаю его как "ПустойКаталог"
		И я переключаюсь во временный каталог "ПустойКаталог"
		И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install ./"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "precommit4onec v24.05"
		И Вывод команды "oscript" содержит "не является репозиторием git"

Сценарий: Установка precommit4onec во вложенные каталоги
	Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install ./ -r"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "precommit4onec v24.05"
		И В каталоге ".git/hooks" репозитория "Репозиторий1" есть файл "pre-commit"
		И В каталоге ".git/hooks" репозитория "Репозиторий2" есть файл "pre-commit"

Сценарий: Рекурсивная установка precommit4oneсне корректно обрабатывает папки не репо
	Когда Я создаю каталог "!_test1" внутри каталога "КаталогРепозиториев"
		  И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install ./ -r"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "не является репозиторием git"

Сценарий: Рекурсивная установка precommit4oneс выполняется, когда папке с репозиториями есть папки не репо
	Когда Я создаю каталог "!_test1" внутри каталога "КаталогРепозиториев"
		  И Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os install ./ -r"
	Тогда Код возврата команды "oscript" равен 0
		И Я сообщаю вывод команды "oscript"
		И Вывод команды "oscript" содержит "precommit4onec v24.05"
		И В каталоге ".git/hooks" репозитория "Репозиторий1" есть файл "pre-commit"
		И В каталоге ".git/hooks" репозитория "Репозиторий2" есть файл "pre-commit"
