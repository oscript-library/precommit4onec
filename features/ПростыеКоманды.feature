# language: ru

Функциональность: Выполнение команды продукта

Как разработчик
Я хочу иметь возможность выполнять команды продукта
Чтобы выполнять коллективную разработку приложения для OneScript

Контекст:
    Допустим Я очищаю параметры команды "oscript" в контексте 
    И я включаю отладку лога с именем "oscript.app.precommit4onec"
    # И я включаю отладку лога с именем "bdd"

Сценарий: Получение версии продукта
    Когда Я выполняю команду "oscript" с параметрами "src/main.os version"
    Тогда Я сообщаю вывод команды "oscript"
    И Вывод команды "oscript" содержит "24.03"
    И Вывод команды "oscript" не содержит "precommit4onec v"
    И Код возврата команды "oscript" равен 0

Сценарий: Получение помощи продукта
    Когда Я выполняю команду "oscript" с параметрами "src/main.os help"
    Тогда Вывод команды "oscript" содержит 
    """
    precommit4onec v24.03
    Возможные команды:
    help        - Выводит справку по командам
    version     - Выводит версию приложения
    precommit   - Выполняет сценарии precommit
    install     - Выполняет подключение (установку) precommit hook'а в репозиторий
    configure   - Выполняет настройку репозитория
    exec-rules  - Выполняет указанные сценарии в каталоге репозитория принудительно, без обращения к git
    """
    И Код возврата команды "oscript" равен 0

Сценарий: Вызов исполняемого файла без параметров
    Когда Я выполняю команду "oscript" с параметрами "src/main.os"
    Тогда Вывод команды "oscript" содержит
    """
    precommit4onec v24.03
    Возможные команды:
    help        - Выводит справку по командам
    version     - Выводит версию приложения
    precommit   - Выполняет сценарии precommit
    install     - Выполняет подключение (установку) precommit hook'а в репозиторий
    configure   - Выполняет настройку репозитория
    exec-rules  - Выполняет указанные сценарии в каталоге репозитория принудительно, без обращения к git
    """
    И Код возврата команды "oscript" равен 5
