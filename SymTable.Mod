MODULE SymTable;
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

PROCEDURE NewObj*(id: ARRAY OF CHAR; class: INTEGER): Object;
BEGIN
	
END NewObj;

PROCEDURE Init;
VAR in: Object;
BEGIN
	NEW(curScope);
	curScope.class := Head;
	curScope.next := NIL;
	
	NEW(curScope.dsc);
	curScope.dsc.class := Head;
	
	NEW(in);
	in.class := Typ;
	in.name := "INTEGER";
	in.next := NIL;
	in.dsc := NIL;
	in.type := MakeType(Int);
	curScope.dsc.next := in;
	
END Init;

END SymTable.
