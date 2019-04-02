(* Главный файл компилятора.
Открывает файл с исходным кодом, подлежащим компиляции,
передаёт его лексическому (Scanner) и синтаксическому анализатору (Parser).
Запускает главную процедуру синтаксического анализатора. *)

MODULE Compiler;
IMPORT Out, Files, S := Scanner, P := Parser, ST := SymTable;
CONST filename = "Test.Mod";
VAR F: Files.File;
BEGIN
  F := Files.Old(filename); (* В будущем название будет браться из консоли *)
  IF F = NIL THEN
    Out.String("Файл '"); Out.String(filename); Out.String("' не найден.")
  ELSE
    S.Init(F);
    ST.Init;
    IF P.Compile() THEN Out.String("Компиляция прошла успешно.")
    ELSE Out.String("В ходе компиляции возникли ошибки.")
    END;
    Files.Close(F)
  END;
  Out.Ln
END Compiler.
