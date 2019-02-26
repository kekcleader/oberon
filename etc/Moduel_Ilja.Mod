MODULE Moduel;
IMPORT Out, Files;
VAR
  F: Files.File;
  r: Files.Rider;

PROCEDURE ReadAll;
VAR ch: CHAR;
BEGIN
  Files.Read(r, ch);
  WHILE ~r.eof DO
    Out.Char(ch);
    Files.Read(r, ch)
  END
END ReadAll;

BEGIN
  F := Files.Old('Test.Mod');
  IF F = NIL THEN
    Out.String('Файл не найден.'); Out.Ln
  ELSE
    Files.Set(r, F, 0);
    ReadAll
  END
END Moduel.
