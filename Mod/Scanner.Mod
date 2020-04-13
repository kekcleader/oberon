MODULE Scanner;
IMPORT Out, Files;
CONST
  (*Лексемы*)
  null = 0; times* = 1; rdiv* = 2; div* = 3; mod* = 4;
  and* = 5; plus* = 6; minus* = 7; or* = 8; eql* = 9;
  neq* = 10; lss* = 11; leq* = 12; gtr* = 13; geq* = 14;
  in* = 15; is* = 16; arrow* = 17; period* = 18;
  char* = 20; int* = 21; real* = 22; false* = 23; true* = 24;
  nil* = 25; string* = 26; not* = 27; lparen* = 28; lbrak* = 29;
  lbrace* = 30; ident* = 31;
  if* = 32; while* = 34; repeat* = 35; case* = 36; for* = 37;
  comma* = 40; colon* = 41; becomes* = 42; upto* = 43; rparen* = 44;
  rbrak* = 45; rbrace* = 46; then* = 47; of* = 48; do* = 49;
  to* = 50; by* = 51; semicolon* = 52; end* = 53; bar* = 54;
  else* = 55; elsif* = 56; until* = 57; return* = 58;
  array* = 60; record* = 61; pointer* = 62; const* = 63; type* = 64;
  var* = 65; procedure* = 66; begin* = 67; import* = 68; module* = 69;
  eot = 70;

VAR r: Files.Rider;
    ch: CHAR;
    id*: ARRAY 32 OF CHAR;
    idlen*: INTEGER;
    ival*: INTEGER;
    sval*: ARRAY 1024 OF CHAR;
    slen*: INTEGER;
    error*: BOOLEAN;

PROCEDURE Color(n: INTEGER);
BEGIN
  Out.Char(CHR(27)); Out.Char("[");
  Out.Int(n, 0); Out.Char("m")
END Color;

PROCEDURE Mark*(msg: ARRAY OF CHAR);
BEGIN
  error := TRUE;
  Color(41); Color(97);
  Out.String("Ошибка на поз. ");
  Out.Int(SHORT(Files.Pos(r)), 0);
  Out.String(": "); Out.String(msg);
  Out.Char("."); Color(0); Out.Ln
END Mark;

PROCEDURE ReadCh;
BEGIN
  IF r.eof THEN ch := 0X
  ELSE Files.Read(r, ch)
  END
END ReadCh;

PROCEDURE Get*(VAR sym: INTEGER);
VAR d: ARRAY 30 OF INTEGER; (*digits*)
  i, dlen, base: INTEGER;
BEGIN
  WHILE (ch # 0X) & (ch <= " ") DO
    ReadCh
  END;

  IF r.eof THEN sym := eot
  ELSIF ch = "," THEN sym := comma; ReadCh
  ELSIF ch = "." THEN sym := period; ReadCh
  ELSIF ch = ";" THEN sym := semicolon; ReadCh
  ELSIF ch = "+" THEN sym := plus; ReadCh
  ELSIF ch = "-" THEN sym := minus; ReadCh
  ELSIF ch = "*" THEN sym := times; ReadCh
  ELSIF ch = "/" THEN sym := rdiv; ReadCh
  ELSIF ch = "&" THEN sym := and; ReadCh
  ELSIF ch = "~" THEN sym := not; ReadCh
  ELSIF ch = "(" THEN sym := lparen; ReadCh
  ELSIF ch = ")" THEN sym := rparen; ReadCh
  ELSIF ch = "[" THEN sym := lbrak; ReadCh
  ELSIF ch = "]" THEN sym := rbrak; ReadCh
  ELSIF ch = "{" THEN sym := lbrace; ReadCh
  ELSIF ch = "}" THEN sym := rbrace; ReadCh
  ELSIF ch = "=" THEN sym := eql; ReadCh
  ELSIF ch = "#" THEN sym := neq; ReadCh
  ELSIF ch = "<" THEN ReadCh;
    IF ch = "=" THEN sym := leq; ReadCh
    ELSE sym := lss
    END
  ELSIF ch = ">" THEN ReadCh;
    IF ch = "=" THEN sym := geq; ReadCh
    ELSE sym := gtr
    END
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
    d[0] := ORD(ch) - ORD("0"); ReadCh;
    dlen := 1;
    WHILE ("0" <= ch) & (ch <= "9") OR
          ("A" <= ch) & (ch <= "F") DO
      IF dlen < LEN(d) THEN
        IF ("0" <= ch) & (ch <= "9") THEN d[dlen] := ORD(ch) - ORD("0")
        ELSE d[dlen] := ORD(ch) - ORD("A") + 10
        END;
        INC(dlen)
      ELSE Mark("Слишком длинное число")
      END;
      ReadCh
    END;
    sym := int;
    IF (ch = "X") OR (ch = "H") THEN
      base := 16;
      IF ch = "X" THEN sym := char END;
      ReadCh
    ELSE base := 10
    END;
    ival := 0; i := 0;
    WHILE i < dlen DO
      IF (base = 10) & (d[i] >= 10) THEN
        Mark("Некорректное число")
      END;
      ival := ival * base + d[i];
      INC(i)
    END
  ELSIF ch = 22X THEN ReadCh; sym := string;
    slen := 0;
    WHILE (ch # 22X) & (ch >= " ") & (slen < LEN(sval) - 1) DO
      sval[slen] := ch;
      INC(slen);
      ReadCh
    END;
    IF ch = 0X THEN Mark("Неожиданный конец файла")
    ELSIF ch < " " THEN Mark("Недопустимая литера в строке")
    ELSIF ch # 22X THEN Mark("Слишком длинная строка")
    END;
    sval[slen] := 0X;
      (*Промотка до ближайшей кавычки*)
    WHILE (ch # 0X) & (ch # 22X) DO ReadCh END;
    ReadCh
  ELSE
    sym := null;
    ReadCh
  END
END Get;

PROCEDURE Init*(F: Files.File);
BEGIN
  Files.Set(r, F, 0);
  ReadCh;
  error := FALSE
END Init;

END Scanner.
