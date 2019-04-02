MODULE Parser;
IMPORT Out, Files, S := Scanner, ST := SymTable, Gen := Generator;
VAR sym: INTEGER;

PROCEDURE Import;
BEGIN
  (* Здесь будет обработка IMPORT *)
END Import;

PROCEDURE Type(VAR x: Gen.Item);
BEGIN
  IF sym = S.ident THEN
    IF S.id = "INTEGER" THEN
      S.Get(sym);
      x.mode := ST.Typ;
      x.type := NIL
    ELSE
      S.Mark("Ожидается INTEGER")
    END
  ELSE
    S.Mark("Ожидается тип")
  END
END Type;

(* Объявления = [CONST {ОбъявлениеКонстант ";"}]
		[TYPE {ОбъявлениеТипов ";"}]
		[VAR {ОбъявлениеПеременных ";"}]
		{ОбъявлениеПроцедуры ";"}.
ОбъявлениеПеременных = Идентификаторы ":" Тип.
Идентификаторы = Идентификатор {"," Идентификатор}.
Тип = уточнИдент | ТипМассив | ТипЗапись | ТипУказатель | ПроцедурныйТип.
Но в начале будет только VAR, поэтому используется упрощённый вариант:
Объявления = [VAR {ОбъявлениеПеременных ";"}].
ОбъявлениеПеременных = Идентификаторы ":" Тип.
Идентификаторы = Идентификатор {"," Идентификатор}.
Тип = Идентификатор. *)

PROCEDURE Declarations;
VAR x: Gen.Item;
    i, n: INTEGER;
    o: ST.Object;
    names: ARRAY 30, 32 OF CHAR;
BEGIN
  IF sym = S.var THEN (* 1. Если считано слово VAR, то: *)
    S.Get(sym); (* Переходим к названию первой переменной *)
    WHILE sym = S.ident DO
      names[0] := S.id;
      S.Get(sym); (* Переходим к запятой или к двоеточию *)
      n := 1;
      WHILE sym = S.comma DO
        S.Get(sym); (* Переходим к названию следующей перменной *)
        IF sym = S.ident THEN
          IF n < LEN(names) THEN
            names[n] := S.id;
            INC(n)
          ELSE
            S.Mark("Слишком много переменных")
          END
        ELSE
          S.Mark("Ожидается идентификатор")
        END;
        S.Get(sym) (* Переходим к запятой или к двоеточию *)
      END;
      IF sym = S.colon THEN
        S.Get(sym);
        Type(x);
        FOR i := 0 TO n - 1 DO
          o := ST.NewObj(names[i], ST.Var)
        END;
        IF sym = S.semicol THEN
          S.Get(sym)
        ELSE
          S.Mark("Ожидается точка с запятой")
        END
      ELSE
        S.Mark("Ожидается двоеточие")
      END
    END
  END
END Declarations;

(* Операторы = Оператор {";" Оператор}.
Оператор = Присваивание | ВызовПроцедуры | ОператорIf |
              ОператорCase | ОператорWhile | ОператорRepeat |
              ОператорFor | "".
"Statements"/"Операторы" означает последовательность операторов. *)

PROCEDURE Statements;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  REPEAT
    IF sym = S.semicol THEN S.Get(sym) END;
    IF sym = S.ident THEN name := S.id; S.Get(sym);
      IF sym = S.equ THEN S.Get(sym); sym := S.becomes; S.Mark("Ожидается :=") END;
      IF sym = S.becomes THEN S.Get(sym);
        IF sym = S.int THEN
          Out.String("Переменной "); Out.String(name);
          Out.String(" присвоено значение "); Out.Int(S.ival, 0); Out.Ln;
          S.Get(sym)
        ELSE S.Get(sym);
          S.Mark("Можно присваивать только числа")
        END
      ELSE S.Mark("Ожидается :=")
      END
    END
  UNTIL sym # S.semicol
END Statements;

(* Модуль = MODULE идент ";" Объявления [BEGIN Операторы] END идент ".". *)
PROCEDURE Module;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  IF sym = S.module THEN
    S.Get(sym);
    IF sym = S.ident THEN name := S.id; S.Get(sym)
    ELSE S.Mark("Ожидается идентификатор"); name[0] := 0X
    END;
    IF sym = S.semicol THEN S.Get(sym)
    ELSE S.Mark("Ожидается точка с запятой")
    END;
    Import;
    Declarations;
    IF sym = S.begin THEN S.Get(sym); Statements END;
    IF sym = S.end THEN
      S.Get(sym);
      IF sym = S.ident THEN
        IF name # S.id THEN S.Mark("Название модуля не совпадает") END;
        S.Get(sym)
      ELSE
        S.Mark("Ожидается название модуля")
      END;
      IF sym # S.period THEN S.Mark("Нет точки в конце модуля") END
    ELSE S.Mark("Ожидается END")
    END
  ELSE S.Mark("Ожидается модуль")
  END
END Module;

(* Разбирает лексемы, получаемые из модуля Scanner, в соответствии
с синтаксисом языка Оберон. Возвращает TRUE в случае
успешной компиляции. Вызывается из модуля Compiler.
В будущем будет вызывать кодогенератор (из отдельного модуля). *)
PROCEDURE Compile*(): BOOLEAN;
BEGIN
  Gen.WriteDummy; (* Сгенерировать исполнимый файл. Хардкод. *)
  S.Get(sym); (* Получить наперёд одну лексему *)
  Module; (* Запустить разбор синтаксической структуры МОДУЛЬ *)
  ST.Display;
  RETURN ~S.error
END Compile;

END Parser.
