#language: ru

Функциональность: Генерация скрипта автодополнения

Как пользователь ovm
Я хочу получить скрипт автодополнения для моей оболочки
Чтобы удобно использовать ovm в терминале

Контекст:
    Допустим Я устанавливаю переменной среды "OVM_INSTALL_PATH" значение "./temp/ovm"

Сценарий: Генерация completions для bash
    Когда Я выполняю команду "oscript ./src/cmd/ovm.os completions --shell bash"
    Тогда я вижу в консоли вывод "_ovm_completions"
    И я вижу в консоли вывод "complete -F _ovm_completions ovm"

Сценарий: Генерация completions для bash с коротким флагом
    Когда Я выполняю команду "oscript ./src/cmd/ovm.os completions -s bash"
    Тогда я вижу в консоли вывод "_ovm_completions"
    И я вижу в консоли вывод "complete -F _ovm_completions ovm"

Сценарий: Генерация completions для zsh
    Когда Я выполняю команду "oscript ./src/cmd/ovm.os completions --shell zsh"
    Тогда я вижу в консоли вывод "#compdef ovm"

Сценарий: Генерация completions для pwsh
    Когда Я выполняю команду "oscript ./src/cmd/ovm.os completions --shell pwsh"
    Тогда я вижу в консоли вывод "Register-ArgumentCompleter"
