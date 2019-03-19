MODULE Parser;
IMPORT Out, Files, S := Scanner;
VAR sym: INTEGER;

PROCEDURE Import;
BEGIN
  (* Здесь будет обработка IMPORT *)
END Import;

PROCEDURE Declarations;
BEGIN
  (* Здесь будет обработка CONST, TYPE, VAR и объявлений процедур *)
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
        S.Get(sym);
        IF sym # S.period THEN S.Mark("Нет точки в конце модуля") END
      END
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
  S.Get(sym); (* Получить наперёд одну лексему *)
  Module; (* Запустить разбор синтаксической структуры МОДУЛЬ *)
  RETURN ~S.error
END Compile;

END Parser.
