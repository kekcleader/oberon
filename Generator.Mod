MODULE Generator;
IMPORT ST := SymTable;
TYPE
  Item* = RECORD
		mode*: INTEGER; (* Режим предмета, используются константы из SymTable *)
		type*: ST.Type
  END;
END Generator.
