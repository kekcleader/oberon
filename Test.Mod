MODULE Test;
IMPORT O := Out, In;
VAR a, b, c, n: INTEGER;
  d, f: CHAR;
BEGIN
  a := 4;
  n := 5;
  a := a * n;
  In.Int(n);
  O.Char(46X);
  O.Int(351, 0);
  O.Ln
END Test.
