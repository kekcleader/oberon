MODULE SymTable;
IMPORT Out, S := Scanner;
CONST
	(* Классы объектов (и, одновременно, режимы предметов) *)
	Head* = 0; Var* = 2; Typ* = 5;
	
	(* Формы типов *)
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

PROCEDURE Init*;
VAR in: Object;
BEGIN
	NEW(curScope);
	curScope.class := Head;
	curScope.next := NIL;

	NEW(curScope.dsc);
	curScope.dsc.class := Head;
	curScope.dsc.dsc := NIL;

	NEW(in);
	in.class := Typ;
	in.name := "INTEGER";
	in.next := NIL;
	in.dsc := NIL;
	in.type := MakeType(Int);
	curScope.dsc.next := in
END Init;

PROCEDURE Display*;
VAR h, p: Object;
BEGIN
  Out.String("Диагностика горизонта событий"); Out.Ln;
  h := curScope;
  WHILE h # NIL DO
    p := h.next;
    WHILE p # NIL DO
      Out.String(p.name);
      Out.String(": class ");
      Out.Int(p.class, 0);
      Out.Ln;
      p := p.next
    END;
    Out.String("Конец области видимости"); Out.Ln;
    h := h.dsc
  END
END Display;

END SymTable.
