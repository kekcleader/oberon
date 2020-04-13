MODULE SymTable;
IMPORT Out, S := Scanner;
CONST
  (* Классы объектов (и одновременно режимы предметов) *)
  Head* = 0; Var* = 2; Typ* = 5;

  (* Формы типов *)
  Char* = 3;
  Int* = 4;

TYPE
  Type* = POINTER TO TypeDesc;
  TypeDesc* = RECORD
    form*: INTEGER (* Форма типа *)
  END;

  Object* = POINTER TO ObjDesc;
  ObjDesc* = RECORD
    class*: INTEGER; (* Класс объекта *)
    type*: Type;
    name*: ARRAY 32 OF CHAR;
    next*, dsc*: Object
  END;
VAR
  curScope: Object;

  charType*, intType*: Type;

(*Для удобочитаемой отладки*)
PROCEDURE OutType*(t: Type);
BEGIN
  IF t.form = Int THEN Out.String("целое число")
  ELSIF t.form = Char THEN Out.String("литера")
  ELSE Out.Int(t.form, 0)
  END
END OutType;

PROCEDURE MakeType(form: INTEGER): Type;
VAR t: Type;
BEGIN
  NEW(t);
  t.form := form;
  RETURN t
END MakeType;

PROCEDURE NewObj*(name: ARRAY OF CHAR; class: INTEGER): Object;
VAR o, p: Object;
BEGIN
  p := curScope;
  WHILE (p.next # NIL) & (p.next.name # name) DO p := p.next END;
  IF p.next = NIL THEN
    NEW(o);
    o.class := class;
    o.name := name;
    o.next := NIL;
    p.next := o
  ELSE
    o := p.next;
    S.Mark("Такой объект уже есть")
  END;
  RETURN o
END NewObj;

(*Предусловие: sym = S.ident*)
PROCEDURE ThisObj*(): Object;
VAR o, p: Object;
BEGIN
  p := curScope;
  WHILE p # NIL DO
    o := p.next;
    WHILE (o # NIL) & (o.name # S.id) DO
      o := o.next
    END;
    IF o = NIL THEN p := p.dsc
    ELSE p := NIL
    END
  END;
  RETURN o
END ThisObj;

PROCEDURE Init*;
VAR o: Object;
BEGIN
  NEW(curScope);
  curScope.class := Head;
  curScope.name[0] := 0X;
  curScope.next := NIL;

  NEW(curScope.dsc);
  curScope.dsc.class := Head;
  curScope.dsc.name[0] := 0X;
  curScope.dsc.dsc := NIL;

  NEW(o);
  o.class := Typ;
  o.name := "CHAR";
  o.next := NIL;
  o.dsc := NIL;
  charType := MakeType(Char);
  o.type := charType;
  curScope.dsc.next := o;

  NEW(o);
  o.class := Typ;
  o.name := "INTEGER";
  o.next := NIL;
  o.dsc := NIL;
  intType := MakeType(Int);
  o.type := intType;
  curScope.dsc.next.next := o
END Init;

PROCEDURE Display*;
VAR h, p: Object;
BEGIN
  Out.String("Содержимое символьной таблицы:"); Out.Ln;
  h := curScope;
  WHILE h # NIL DO
    p := h.next;
    WHILE p # NIL DO
      Out.String("  "); Out.String(p.name); Out.String(": ");
      IF p.class = Head THEN Out.String("заголовочный")
      ELSIF p.class = Var THEN
        Out.String("переменная типа "); OutType(p.type)
      ELSIF p.class = Typ THEN Out.String("тип")
      END;
      Out.Ln;
      p := p.next
    END;
    IF h.dsc # NIL THEN
      Out.String("Следующая область видимости:"); Out.Ln
    END;
    h := h.dsc
  END
END Display;

END SymTable.
