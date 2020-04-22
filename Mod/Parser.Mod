MODULE Parser;
IMPORT Out, Files, S := Scanner, ST := SymTable, Gen := Generator;
VAR sym: INTEGER;
  dc: INTEGER; (*Счётчик данных (data counter)*)
  dummy: ST.Object; (*Болванка, см. QualIdent*)

PROCEDURE ^Expression(VAR x: Gen.Item);

(*импорт = идент [":=" идент].*)
PROCEDURE Import;
VAR ident1, ident2: ARRAY 32 OF CHAR;
BEGIN
  IF sym = S.ident THEN
    ident1 := S.id;
    S.Get(sym);
    IF sym = S.becomes THEN
      S.Get(sym);
      IF sym = S.ident THEN
        ident2 := S.id;
        S.Get(sym)
      ELSE
        S.Mark("Ожидается идентификатор")
      END
    ELSE
      ident2 := ident1
    END;
    ST.Import(ident1, ident2)
  ELSE
    S.Mark("Ожидается идентификатор")
  END
END Import;

(*СписокИмпорта = IMPORT импорт {"," импорт} ";".*)
PROCEDURE ImportList;
BEGIN
  IF sym = S.import THEN
    S.Get(sym);
    Import;
    WHILE sym = S.comma DO
      S.Get(sym);
      Import
    END;
    IF sym = S.semicolon THEN
      S.Get(sym)
    ELSE
      S.Mark("Ожидается точка с запятой")
    END
  END
END ImportList;

PROCEDURE Type(VAR tp: ST.Type);
VAR o: ST.Object;
BEGIN
  tp := ST.intType; (*Тип по умолчанию, используется в случае ошибки*)

  IF sym = S.ident THEN
    o := ST.ThisObj();
    S.Get(sym);
    IF o = NIL THEN
      S.Mark("Нет такого типа")
    ELSIF o.class # ST.Typ THEN
      S.Mark("Это не тип")
    ELSE
      tp := o.type
    END
  ELSE (*!TODO учесть ARRAY, RECORD и др.*)
    S.Mark("Ожидается тип")
  END
END Type;

(*Объявления = [CONST {ОбъявлениеКонстант ";"}]
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
Тип = Идентификатор.*)
PROCEDURE Declarations(VAR varsize: INTEGER);
VAR tp: ST.Type;
    i, n: INTEGER;
    o: ST.Object;
    names: ARRAY 30, 32 OF CHAR;
BEGIN
  IF sym = S.var THEN (*1. Если считано слово VAR, то:*)
    S.Get(sym); (*Переходим к названию первой переменной*)
    WHILE sym = S.ident DO
      names[0] := S.id;
      S.Get(sym); (*Переходим к запятой или к двоеточию*)
      n := 1;
      WHILE sym = S.comma DO
        S.Get(sym); (*Переходим к названию следующей перменной*)
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
        S.Get(sym) (*Переходим к запятой или к двоеточию*)
      END;
      IF sym = S.colon THEN
        S.Get(sym);
        Type(tp);
        FOR i := 0 TO n - 1 DO
          o := ST.NewObj(names[i], ST.Var);
          o.type := tp;
          o.val := varsize;
          INC(varsize, 4);(*!TODO учитывать размер типа и выравнивание*)
          Out.String("Объявлена переменная "); Out.String(names[i]);
          Out.String(" типа "); ST.OutType(o.type);
          Out.String(" (адрес "); Out.Int(o.val, 0); Out.String(").");
          Out.Ln
        END;
        IF sym = S.semicolon THEN
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

(*УПРОЩЕНО: множитель = число | литера | идент | "(" выражение ")".*)
PROCEDURE Factor(VAR x: Gen.Item);
VAR o: ST.Object;
BEGIN
  IF sym = S.int THEN
    x.mode := ST.Const;
    x.type := ST.intType;
    x.val := S.ival;
    Out.String("Прочитано число ");
    Out.Int(S.ival, 0); Out.Ln;
    S.Get(sym)
  ELSIF sym = S.char THEN
    x.mode := ST.Const;
    x.type := ST.charType;
    x.val := S.ival;
    Out.String("Прочитана литера ");
    Out.Char(CHR(S.ival)); Out.Ln;
    S.Get(sym)
  ELSIF sym = S.string THEN
    x.mode := ST.Const;
    x.type := ST.charType;
    x.val := ORD(S.sval[0]);
    IF S.slen = 1 THEN
      Out.String("Прочитана литера ");
      Out.Char(S.sval[0]); Out.Ln
    ELSE
      S.Mark("Допускается только CHAR")
    END;
    S.Get(sym)
  ELSIF sym = S.ident THEN
    o := ST.ThisObj();
    S.Get(sym);
    IF o = NIL THEN
      S.Mark("Идентификатор не объявлен")
    ELSE
      x.mode := o.class;
      x.type := o.type;
      x.val := o.val
    END
  ELSIF sym = S.lparen THEN
    S.Get(sym);
    Expression(x);
    IF sym = S.rparen THEN S.Get(sym)
    ELSE S.Mark("Ожидается )")
    END
  ELSE
    S.Mark("Ожидается число, идентификатор или (")
  END
END Factor;

(*слагаемое = множитель {ОперацияУмножения множитель}.*)
PROCEDURE Term(VAR x: Gen.Item);
VAR op: INTEGER;
  y: Gen.Item;
BEGIN
  Factor(x);
  WHILE (sym = S.times) OR (sym = S.div) OR (sym = S.mod) DO
    op := sym;
    S.Get(sym);
    Factor(y);
    IF (x.type.form = ST.Int) & (y.type.form = ST.Int) THEN
      IF (x.mode = ST.Const) & (y.mode = ST.Const) THEN
        IF op = S.times THEN
          x.val := x.val * y.val (*!TODO проверить переполнение*)
        ELSE (*DIV OR MOD*)
          IF op = S.div THEN (*!TODO проверить деление на нуль*)
            x.val := x.val DIV y.val
          ELSE
            x.val := x.val MOD y.val
          END
        END
      ELSE
        IF op = S.times THEN
          Out.String("умножение")
        ELSIF op = S.div THEN
          Out.String("деление")
        ELSE
          Out.String("остаток от деления")
        END
      END
    ELSE
      S.Mark("Операция неприменима")
    END;
    Out.Ln
  END
END Term;

(*ПростоеВыражение = ["+"|"-"] слагаемое {ОператорСложения слагаемое}.*)
PROCEDURE SimpleExpression(VAR x: Gen.Item);
VAR minus: BOOLEAN;
  op: INTEGER;
  y: Gen.Item;
BEGIN
  minus := FALSE;
  IF sym = S.plus THEN
    S.Get(sym)
  ELSIF sym = S.minus THEN
    minus := TRUE;
    S.Get(sym)
  END;
  Term(x);
  IF minus THEN
    IF x.type.form = ST.Int THEN
      IF x.mode = ST.Const THEN
        x.val := -x.val
      ELSE
        Out.String("Унарный минус"); Out.Ln
      END
    ELSE
      S.Mark("Операция унарного минуса неприменима")
    END
  END;
  WHILE (sym = S.plus) OR (sym = S.minus) DO
    op := sym;
    S.Get(sym);
    Term(y);
    IF (x.type.form = ST.Int) & (y.type.form = ST.Int) THEN
      IF (x.mode = ST.Const) & (y.mode = ST.Const) THEN
        IF op = S.plus THEN
          INC(x.val, y.val) (*!TODO проверить переполнение*)
        ELSE
          DEC(x.val, y.val) (*!TODO проверить переполнение*)
        END
      ELSE
        IF op = S.plus THEN
          Out.String("плюс")
        ELSE
          Out.String("минус")
        END
      END
    ELSE
      S.Mark("Операция неприменима")
    END;
    Out.Ln
  END
END SimpleExpression;

(*выражение = ПростоеВыражение [отношение ПростоеВыражение].*)
PROCEDURE Expression(VAR x: Gen.Item);
BEGIN
  SimpleExpression(x)
END Expression;

(*Присваивание = идент ":=" выражение.
x - то, что слева от знака присваивания,
y - то, что справа от знака присваивания.*)
PROCEDURE Assignment(VAR x: Gen.Item);
VAR y: Gen.Item;
BEGIN
  S.Get(sym); (*пропускаем :=*)
  Expression(y);
  IF x.type = y.type THEN
    Out.String("Переменной по адресу ");
    Out.Int(x.val, 0);
    Out.String(" присвоено значение ");
    Out.Int(y.val, 0); Out.Char("."); Out.Ln
  ELSE
    S.Mark("Не совпадают типы")
  END
END Assignment;

(*уточнИдент = [идент "."] идент.
Первый идент - это модуль. *)
PROCEDURE QualIdent(VAR o: ST.Object);
BEGIN
  o := ST.ThisObj();
  S.Get(sym);
  IF o = NIL THEN
    S.Mark("Нет такого объекта")
  ELSE (*Объект найден...*)
    IF (sym = S.period) & (o.class = ST.Mod) THEN (*...и это модуль*)
      S.Get(sym);
      o := ST.ThisObjInModule(o);
      S.Get(sym);
      IF o = NIL THEN S.Mark("В модуле нет такого объекта") END
    END
  END;
  IF o = NIL THEN o := dummy END
END QualIdent;

(*Designator - обозначение.
Обозначение = уточнИдент {селектор}.
селектор = "[" выражение "]" | ...
Но здесь упрощено: Обозначение = уточнИдент.*)
PROCEDURE Designator(VAR o: ST.Object);
BEGIN
  QualIdent(o) (*!TODO обработать селекторы*)
END Designator;

PROCEDURE Parameter(par: ST.Object);
VAR x: Gen.Item;
BEGIN
  Expression(x);
  IF par # NIL THEN
    IF x.type.form # par.type.form THEN
      S.Mark("Несогласование типов")
      (*!TODO вывести типы формального и фактического параметров*)
    ELSE
      Out.String("Параметр "); Out.Int(x.val, 0); Out.Char("."); Out.Ln
    END
  END
END Parameter;

(*ФактическиеПараметры = "(" [выражение {"," выражение}] ")".
Предусловие: sym = S.lparen. Обрабатывает до ")" включительно.*)
PROCEDURE ActualParameters(VAR x: Gen.Item);
VAR y: Gen.Item;
  par: ST.Object;
  n: INTEGER; (*Фактическое количество параметров*)
BEGIN
  S.Get(sym);
  n := 0;
  IF sym # S.rparen THEN
    par := x.type.dsc;
    Parameter(par);
    INC(n);
    WHILE sym = S.comma DO
      S.Get(sym);
      IF par # NIL THEN par := par.next END;
      Parameter(par);
      INC(n)
    END
  END;
  IF sym = S.rparen THEN S.Get(sym)
  ELSE S.Mark("Не закрыта скобка")
  END;
  (*Проверка совпадения количества параметров*)
  IF n > x.type.nofpar THEN
    S.Mark("Слишком много фактических параметров")
  ELSIF n < x.type.nofpar THEN
    S.Mark("Недостаточно фактических параметров")
  END
END ActualParameters;

(*Операторы = Оператор {";" Оператор}.
Оператор = [Присваивание | ВызовПроцедуры | ОператорIf |
           ОператорCase | ОператорWhile | ОператорRepeat | ОператорFor].
Statements/Операторы означает последовательность операторов.*)
PROCEDURE Statements;
VAR x: Gen.Item;
  o: ST.Object;
BEGIN
  REPEAT
    WHILE sym = S.semicolon DO S.Get(sym) END;
    IF sym = S.ident THEN
      Designator(o);
      Gen.MakeItem(x, o);
      IF sym = S.eql THEN sym := S.becomes; S.Mark("Ожидается :=") END;
      IF sym = S.becomes THEN Assignment(x)
      ELSIF sym = S.lparen THEN (*Например: Out.Int(... *)
        IF x.type.form = ST.Proc THEN (*Это действительно процедура*)
          IF x.type.base.form # ST.NoTyp THEN (*Функциональная*)
            S.Mark("Не используется возвращаемое значение")
          ELSE
            ActualParameters(x); (*Обрабатывает до ")" включительно*)
            Gen.Call(x)
          END
        ELSE S.Mark("Это не процедура")
        END
      ELSIF x.type.form = ST.Proc THEN(*Вызов процедуры без параметров*)
        IF x.type.nofpar > 0 THEN S.Mark("Требуются параметры") END;
        IF x.type.base.form # ST.NoTyp THEN (*Функциональная*)
          S.Mark("Не используется возвращаемое значение")
        ELSE
          Gen.Call(x)
        END
      ELSE S.Mark("Инструкция неопознана")
      END
    END
  UNTIL sym # S.semicolon
END Statements;

(*Модуль = MODULE идент ";" [СписокИмпорта] Объявления
[BEGIN Операторы] END идент ".".*)
PROCEDURE Module;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  IF sym = S.module THEN
    S.Get(sym);
    IF sym = S.ident THEN name := S.id; S.Get(sym)
    ELSE S.Mark("Ожидается идентификатор"); name[0] := 0X
    END;
    IF sym = S.semicolon THEN S.Get(sym)
    ELSE S.Mark("Ожидается точка с запятой")
    END;
    ImportList;
    dc := 80002000;
    Declarations(dc);
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

PROCEDURE Init;
BEGIN
  ST.Init;
  NEW(dummy); dummy.class := ST.Var; dummy.type := ST.intType
END Init;

(*Разбирает лексемы, получаемые из модуля Scanner, в соответствии
с синтаксисом языка Оберон. Возвращает TRUE в случае
успешной компиляции. Вызывается из модуля Compiler.
В будущем будет вызывать кодогенератор (из отдельного модуля). *)
PROCEDURE Compile*(): BOOLEAN;
BEGIN
  Init;
  Gen.WriteDummy; (*Сгенерировать исполнимый файл. Хардкод.*)
  S.Get(sym); (* олучить наперёд одну лексему*)
  Module; (*Запустить разбор синтаксической структуры МОДУЛЬ*)
  ST.Display;
  RETURN ~S.error
END Compile;

END Parser.
