MODULE SymTable;
IMPORT Out, S := Scanner;
CONST
  (* Классы объектов (и одновременно режимы предметов) *)
  Head* = 0; Const* = 1; Var* = 2; Par* = 3; Typ* = 5; Mod* = 8;
          (*Par - это вар-параметр*)

  (* Формы типов *)
  Char* = 3;
  Int* = 4;
  NoTyp* = 9;
  Proc* = 10;

TYPE
  Object* = POINTER TO ObjDesc;
  Type* = POINTER TO TypeDesc;
  TypeDesc* = RECORD
    form*: INTEGER; (* Форма типа *)
    size*: INTEGER; (* Размер типа в байтах *)
    nofpar*: INTEGER; (* Количество параметров *)
    base*: Type; (* Тип возвращаемого значения процедуры *)
    dsc*: Object (* Список формальных параметров процедуры *)
  END;

  ObjDesc* = RECORD
    class*: INTEGER; (* Класс объекта *)
    type*: Type;
    name*: ARRAY 32 OF CHAR;
    val*: INTEGER;
    next*, dsc*: Object
  END;

(* Назначение поля val в зависимости от значения поля class (в Object):
class | val
------+-----------------------
Var   | адрес переменной
Const | значение константы
Type  | не используется (пока)   *)

VAR
  curScope: Object;

  charType*, intType*, noType*: Type;

(*Для удобочитаемой отладки*)
PROCEDURE OutType*(t: Type);
BEGIN
  IF t.form = Int THEN Out.String("целое число")
  ELSIF t.form = Char THEN Out.String("литера")
  ELSE Out.Int(t.form, 0)
  END
END OutType;

PROCEDURE MakeType(form, size: INTEGER): Type;
VAR t: Type;
BEGIN
  NEW(t);
  t.form := form;
  t.size := size;
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

PROCEDURE ThisObjInModule*(mod: Object): Object;
VAR o: Object;
BEGIN
  o := mod.dsc;
  WHILE (o # NIL) & (o.name # S.id) DO o := o.next END;
  RETURN o
END ThisObjInModule;

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

(*Добавить процедуру в модуль*)
PROCEDURE AddProc(m: Object; name: ARRAY OF CHAR; key: INTEGER): Object;
VAR o, g: Object;
BEGIN
  NEW(o);
  IF m.dsc = NIL THEN
    m.dsc := o
  ELSE
    g := m.dsc;
    WHILE g.next # NIL DO g := g.next END;
    g.next := o
  END;
  o.class := Const;
  o.name := name;
  o.val := key;
  o.next := NIL;
  o.dsc := NIL;
  o.type := MakeType(Proc, 4);
  o.type.nofpar := 0;
  o.type.base := noType;
  RETURN o
END AddProc;

(*Добавить формальный параметр в процедуру*)
PROCEDURE AddParam(proc: Object; name: ARRAY OF CHAR; varParam: BOOLEAN;
    type: Type; offset: INTEGER);
VAR o, p: Object;
BEGIN
  NEW(p);
  IF proc.type.dsc = NIL THEN
    proc.type.dsc := p
  ELSE
    o := proc.type.dsc;
    WHILE o.next # NIL DO o := o.next END;
    o.next := p
  END;
  INC(proc.type.nofpar);
  IF varParam THEN p.class := Par ELSE p.class := Var END;
  p.name := name;
  p.val := offset; (*?*)
  p.type := type;
  p.next := NIL;
  p.dsc := NIL
END AddParam;

PROCEDURE Import*(alias, modname: ARRAY OF CHAR);
VAR m, o, p: Object;
  tp: Type;
BEGIN
  IF modname = "Out" THEN
    NEW(m);
    curScope.next := m;
    m.class := Mod;
    m.name := alias;
    m.val := 1; (*!FIXME*)
    m.type := NIL;
    m.dsc := NIL;
    (*Out.Char*)
    o := AddProc(m, "Char", 0);
    AddParam(o, "ch", FALSE, charType, 4);
    (*Out.Int*)
    o := AddProc(m, "Int", 1);
    AddParam(o, "n", FALSE, intType, 4);
    AddParam(o, "w", FALSE, intType, 8);
    (*Out.Ln*)
    o := AddProc(m, "Ln", 2)
  ELSIF modname = "In" THEN
    NEW(m);
    m.next := curScope.next;
    curScope.next := m;
    m.class := Mod;
    m.name := alias;
    m.val := 2; (*!FIXME*)
    m.type := NIL;
    m.dsc := NIL;
    (*In.Int*)
    o := AddProc(m, "Int", 0);
    AddParam(o, "n", TRUE, intType, 4)
  ELSE
    S.Mark("Такого модуля не существует")
  END;
  Out.String("Импортируем "); Out.String(modname);
  Out.String(" под псевдонимом "); Out.String(alias);
  Out.Char("."); Out.Ln
END Import;

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
  charType := MakeType(Char, 1);
  o.type := charType;
  curScope.dsc.next := o;

  NEW(o);
  o.class := Typ;
  o.name := "INTEGER";
  o.next := NIL;
  o.dsc := NIL;
  intType := MakeType(Int, 4);
  o.type := intType;
  curScope.dsc.next.next := o;

  noType := MakeType(NoTyp, 4)
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
      ELSIF p.class = Mod THEN Out.String("модуль")
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
