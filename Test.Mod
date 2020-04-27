MODULE Test;
IMPORT Out;
VAR c: CHAR;
BEGIN
  a := a + b;
  c := "!";
  Out.Char("H");
  Out.Char("i");
  Out.Char(c);
  Out.Ln
END Test.

(*Пример*)
SUM EAX, EBX

MOV [0x80002000], DWORD 70 (* c := "F" *)

MOV EAX, [0x80002000]      (* (c) *)
PUSH EAX

CALL 0x80004000            (* Out.Char *)
CALL 0x80004100            (* Out.Ln *)
