&ЛогOVM
Перем Лог;

&Опция(Имя = "shell s", Описание = "Тип оболочки для генерации автодополнения (поддерживается: bash)")
&ТСтрока
&ПоУмолчанию("bash")
&ВОкружении("OVM_COMPLETIONS_SHELL")
Перем ТипОболочки;

&КомандаПриложения(Имя = "completions", Описание = "Вывести скрипт автодополнения команд для выбранной оболочки")
Процедура ПриСозданииОбъекта()
КонецПроцедуры

&ВыполнениеКоманды
Процедура ВыполнениеКоманды() Экспорт

	Если НРег(ТипОболочки) = "bash" Тогда
		Лог.Информация(СкриптАвтодополненияBash());
	Иначе
		ВызватьИсключение СтрШаблон("Оболочка ""%1"" не поддерживается. Поддерживаемые оболочки: bash", ТипОболочки);
	КонецЕсли;

КонецПроцедуры

Функция СкриптАвтодополненияBash()

	Скрипт =
"# ovm bash completions
# Добавьте строку ниже в ~/.bashrc для активации автодополнения:
#   source <(ovm completions --shell bash)

_ovm_completions() {
    local cur prev words cword
    _init_completion 2>/dev/null || {
        COMPREPLY=()
        cur=""${COMP_WORDS[COMP_CWORD]}""
        prev=""${COMP_WORDS[COMP_CWORD-1]}""
        words=(""${COMP_WORDS[@]}"")
        cword=$COMP_CWORD
    }

    local commands=""install i list ls use u which w config run r uninstall delete d completions""

    if [ $cword -eq 1 ]; then
        COMPREPLY=($(compgen -W ""$commands"" -- ""$cur""))
        return 0
    fi

    local command=""${words[1]}""

    case ""$command"" in
        install|i)
            COMPREPLY=($(compgen -W ""--name --clean --x86 --fdd --help"" -- ""$cur""))
            ;;
        list|ls)
            COMPREPLY=($(compgen -W ""--remote --all --quiet --help"" -- ""$cur""))
            ;;
        use|u)
            COMPREPLY=($(compgen -W ""--install --help"" -- ""$cur""))
            ;;
        which|w)
            COMPREPLY=($(compgen -W ""--help"" -- ""$cur""))
            ;;
        run|r)
            COMPREPLY=($(compgen -W ""--help"" -- ""$cur""))
            ;;
        config)
            COMPREPLY=($(compgen -W ""--help"" -- ""$cur""))
            ;;
        uninstall|delete|d)
            COMPREPLY=($(compgen -W ""--force --all --help"" -- ""$cur""))
            ;;
        completions)
            if [ ""$prev"" = ""--shell"" ] || [ ""$prev"" = ""-s"" ]; then
                COMPREPLY=($(compgen -W ""bash"" -- ""$cur""))
            else
                COMPREPLY=($(compgen -W ""--shell --help"" -- ""$cur""))
            fi
            ;;
        *)
            ;;
    esac

    return 0
}

complete -F _ovm_completions ovm";

	Возврат Скрипт;

КонецФункции
