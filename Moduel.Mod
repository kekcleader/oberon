MODULE Moduel;
IMPORT In, Out, Files;
CONST
  null = 0; module = 1; import = 2; const = 3; var = 4; begin = 5;
  end = 6; if = 7; then = 8; else = 9; elsif = 10; while = 11;
  ident = 12; semicol = 13; colon = 14; comma = 15; period = 16;
  becomes = 17; equ = 18; neq = 19; les = 20; leq = 21; gtr = 22; geq = 23;
  lparen = 24; rparen = 25; lbrak = 26; rbrak = 27; lbrace = 28; rbrace = 29;
  int = 30; string = 31; not = 32; and = 33; or = 34; plus = 35; minus = 36;
  rdiv = 37; div = 38; mod = 39; times = 40; eot = 64;
VAR f: Files.File; 
    r: Files.Rider;
    ch: CHAR;
    sym: INTEGER;
    id: ARRAY 32 OF CHAR;
    idlen: INTEGER;
    ival: INTEGER;
    error: BOOLEAN;
    
PROCEDURE ReadCh;
BEGIN
  IF r.eof THEN ch := 0X
  ELSE Files.Read(r, ch)
  END
END ReadCh;

PROCEDURE Get;
BEGIN
  WHILE (ch # 0X) & (ch <= " ") DO
    ReadCh
  END;

  IF r.eof THEN sym := eot
  ELSIF ch = "," THEN sym := comma; ReadCh
  ELSIF ch = "." THEN sym := period; ReadCh
  ELSIF ch = ";" THEN sym := semicol; ReadCh
  ELSIF ch = "+" THEN sym := plus; ReadCh
  ELSIF ch = "-" THEN sym := minus; ReadCh
  ELSIF ch = "&" THEN sym := and; ReadCh
  ELSIF ch = "~" THEN sym := not; ReadCh
  ELSIF ch = "(" THEN sym := lparen; ReadCh
  ELSIF ch = ")" THEN sym := rparen; ReadCh
  ELSIF ch = "[" THEN sym := lbrak; ReadCh
  ELSIF ch = "]" THEN sym := rbrak; ReadCh
  ELSIF ch = "{" THEN sym := lbrace; ReadCh
  ELSIF ch = "}" THEN sym := rbrace; ReadCh
  ELSIF ch = ":" THEN
    ReadCh;
    IF ch = "=" THEN sym := becomes; ReadCh
    ELSE sym := colon
    END
  ELSIF ("A" <= ch) & (ch <= "Z") OR ("a" <= ch) & (ch <= "z") THEN
    id[0] := ch; idlen := 1; ReadCh;
    WHILE ("A" <= ch) & (ch <= "Z") OR
          ("a" <= ch) & (ch <= "z") OR
          ("0" <= ch) & (ch <= "9") DO
      IF idlen < LEN(id) - 1 THEN
        id[idlen] := ch;
        INC(idlen)
      END;
      ReadCh
    END;
    id[idlen] := 0X;
    IF id = "MODULE" THEN sym := module
    ELSIF id = "IMPORT" THEN sym := import
    ELSIF id = "CONST" THEN sym := const
    ELSIF id = "VAR" THEN sym := var
    ELSIF id = "BEGIN" THEN sym := begin
    ELSIF id = "END" THEN sym := end
    ELSIF id = "IF" THEN sym := if
    ELSIF id = "THEN" THEN sym := then
    ELSIF id = "ELSE" THEN sym := else
    ELSIF id = "ELSIF" THEN sym := elsif
    ELSIF id = "WHILE" THEN sym := while
    ELSIF id = "DIV" THEN sym := div
    ELSIF id = "MOD" THEN sym := mod
    ELSIF id = "OR" THEN sym := or
    ELSE sym := ident
    END
  ELSIF ("0" <= ch) & (ch <= "9") THEN
    ival := ORD(ch) - ORD("0"); ReadCh;
    WHILE ("0" <= ch) & (ch <= "9") DO
      ival := ival * 10 + ORD(ch) - ORD("0");
      ReadCh
    END;
    sym := int;
  ELSE
    sym := null;
    ReadCh
  END
END Get;

PROCEDURE Mark(msg: ARRAY OF CHAR);
BEGIN
  error := TRUE;

  Out.String("Ошибка на поз. ");
  Out.Int(SHORT(Files.Pos(r)), 0);
  Out.String(": "); Out.String(msg);
  Out.Char("."); Out.Ln
END Mark;

PROCEDURE Declarations;
BEGIN
  (*Пусто*)
END Declarations;

PROCEDURE StatSeq;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  WHILE (sym = ident) OR (sym = semicol) DO
    IF sym = ident THEN name := id; Get;
      IF sym = equ THEN Get; sym := becomes; Mark("Ожидается :=") END;
      IF sym = becomes THEN Get;
        IF sym = int THEN
          Out.String("Переменной "); Out.String(name);
          Out.String(" присвоено значение "); Out.Int(ival, 0); Out.Ln;
          Get
        ELSE Get;
          Mark("Можно присваивать только числа")
        END
      ELSE Mark("Ожидается :=")
      END
    ELSE Get
    END
  END
END StatSeq;

PROCEDURE Module;
VAR name: ARRAY 32 OF CHAR;
BEGIN
  IF sym = module THEN
    Get;
    IF sym = ident THEN name := id; Get
    ELSE Mark("Ожидается идентификатор"); name[0] := 0X
    END;
    IF sym = semicol THEN Get
    ELSE Mark("Ожидается точка с запятой")
    END;
    Declarations;
    IF sym = begin THEN Get; StatSeq END;
    IF sym = end THEN
      Get;
      IF sym = ident THEN
        IF name # id THEN Mark("Название модуля не совпадает") END;
        Get;
        IF sym # period THEN Mark("Нет точки в конце модуля") END
      END
    ELSE Mark("Ожидается END")
    END
  ELSE Mark("Ожидается модуль")
  END
END Module;

BEGIN
  f := Files.Old("Test.Mod");
  IF f = NIL THEN
    Out.String("No file");
    Out.Ln
  ELSE
    Files.Set(r, f, 0);
    ReadCh;
    Get;
    error := FALSE;
    Module;
    IF error THEN Out.String("Были ошибки."); Out.Ln END
  END
END Moduel.
