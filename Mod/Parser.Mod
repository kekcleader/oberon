MODULE Parser;
IMPORT Out, Files, S := Scanner, ST := SymTable, Gen := Generator;
VAR sym: INTEGER;

PROCEDURE ^Expression;

PROCEDURE Import;
BEGIN
  (* Здесь будет обработка IMPORT *)
END Import;

PROCEDURE Type(VAR x: Gen.Item);
VAR o: ST.Object;
BEGIN
  (*Тип по умолчанию, используется в случае ошибки*)
  x.mode := ST.Typ;
  x.type := ST.intType;

  IF sym = S.ident THEN
    o := ST.ThisObj();
    S.Get(sym);
    IF o # NIL THEN
      IF o.class = ST.Typ THEN
        x.type := o.type
      ELSE
        S.Mark("Это не тип")
      END
    ELSE
      S.Mark("Неизвестный идентификатор")
    END
  ELSE (*!TODO учесть ARRAY, RECORD и др.*)
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
          o := ST.NewObj(names[i], ST.Var);
          o.type := x.type;
          Out.String("Объявлена переменная "); Out.String(names[i]);
          Out.String(" типа "); ST.OutType(o.type); Out.Ln
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
Statements/Операторы означает последовательность операторов. *)

(*УПРОЩЕНО: factor = number | ident | "(" expression ")".*)
PROCEDURE Factor;
BEGIN
  IF sym = S.int THEN
    Out.String("Прочитано число ");
    Out.Int(S.ival, 0); Out.Ln;
    S.Get(sym)
  ELSIF sym = S.ident THEN
    Out.String("Прочитан идентификатор '");
    Out.String(S.id);
    Out.Char("'"); Out.Ln;
    S.Get(sym)
  ELSIF sym = S.lparen THEN
    S.Get(sym);
    Expression;
    IF sym = S.rparen THEN S.Get(sym)
    ELSE S.Mark("Ожидается )")
    END
  ELSE
    S.Mark("Ожидается число, идентификатор или (")
  END
END Factor;

(*term = factor {MulOperator factor}.*)
PROCEDURE Term;
VAR op: INTEGER;
BEGIN
  Factor;
  WHILE (sym = S.times) OR (sym = S.div) OR (sym = S.mod) DO
    op := sym;
    S.Get(sym);
    Factor;
    IF op = S.times THEN
      Out.String("умножение")
    ELSIF op = S.div THEN
      Out.String("деление")
    ELSE
      Out.String("остаток от деления")
    END;
    Out.Ln
  END
END Term;

(*SimpleExpression = ["+"|"-"] term {AddOperator term}.*)
PROCEDURE SimpleExpression;
VAR minus: BOOLEAN;
  op: INTEGER;
BEGIN
  minus := FALSE;
  IF sym = S.plus THEN
    S.Get(sym)
  ELSIF sym = S.minus THEN
    minus := TRUE;
    S.Get(sym)
  END;
  Term;
  IF minus THEN
    Out.String("Унарный минус."); Out.Ln
  END;
  WHILE (sym = S.plus) OR (sym = S.minus) DO
    op := sym;
    S.Get(sym);
    Term;
    IF op = S.plus THEN
      Out.String("плюс")
    ELSE
      Out.String("минус")
    END;
    Out.Ln
  END
END SimpleExpression;

(*expression = SimpleExpression [relation SimpleExpression].*)
PROCEDURE Expression;
BEGIN
  SimpleExpression
END Expression;

(* assignment = ident ":=" expression. *)
PROCEDURE Assignment(name: ARRAY OF CHAR);
BEGIN
  S.Get(sym); (*пропускаем :=*)
  Expression;
  Out.String("Переменной "); Out.String(name);
  Out.String(" присвоено указанное значение."); Out.Ln
END Assignment;

PROCEDURE Statements;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  REPEAT
    WHILE sym = S.semicol DO S.Get(sym) END;
    IF sym = S.ident THEN name := S.id; S.Get(sym);
      IF sym = S.equ THEN sym := S.becomes; S.Mark("Ожидается :=") END;
      IF sym = S.becomes THEN Assignment(name)
      ELSE S.Mark("Ожидается :=") (*!TODO обработать вызов процедуры*)
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
