MODULE Generator;
IMPORT ST := SymTable, Out, Files, Chmod;
CONST fname = "Test";
TYPE
  Item* = RECORD
    mode*: INTEGER; (*Режим предмета, используются константы из SymTable*)
    type*: ST.Type;
    val*: INTEGER
  END;
VAR
  F: Files.File;
  r: Files.Rider;

PROCEDURE Byte(n: INTEGER);
BEGIN
  Files.Write(r, CHR(n))
END Byte;

PROCEDURE Word(n: INTEGER);
BEGIN
  Files.Write(r, CHR(n MOD 100H));
  Files.Write(r, CHR(n DIV 100H))
END Word;

PROCEDURE DWord(n: INTEGER);
BEGIN
  Files.Write(r, CHR(n MOD 100H));
  Files.Write(r, CHR(n DIV 100H MOD 100H));
  Files.Write(r, CHR(n DIV 10000H MOD 100H));
  Files.Write(r, CHR(n DIV 1000000H))
END DWord;

(* Выводит в файл первые 16 байтов заголовка ELF-файла *)
PROCEDURE WriteElfIdent;
BEGIN
  Byte(7FH); (* Магическое значение - ASCII DEL *)
  Byte(ORD("E")); (* Магические значения - слово "ELF" *)
  Byte(ORD("L"));
  Byte(ORD("F"));
  Byte(1); (* Класс ELF-файла: 32-разрядный (бывает ещё 64) *)
  Byte(1); (* Способ кодирования данных: порядок от младшего к старшему (LSB) *)
  Byte(1); (* Версия ELF-файла: бывает только 1 *)
  Byte(0); DWord(0); DWord(0) (* Набивка: просто 9 нулевых байтов *)
END WriteElfIdent;

(* Выводит в файл заголовок ELF-файла *)
PROCEDURE WriteElfHeader;
BEGIN
  WriteElfIdent; (* Выводит первые 16 байтов *)
  Word(2); (* Тип файла: исполнимый файл (бывает ещё .o и .so) *)
  Word(3); (* Архитектура процессора: Intel 386 *)
  DWord(1); (* Версия ELF-файла (ещё раз) *)
  DWord(08040054H); (* Вход в программу. Виртуальный адрес начала исполнения *)
  DWord(52); (* Смещение на начало таблицы программных заголовков *)
  DWord(0); (* Смещение на начало таблицы секций (в исполнимом - не нужны) *)
  DWord(0); (* Флаги процессора (для Intel 386 отсутствуют) *)
  Word(52); (* Размер заголовка ELF-файла в байтах *)
  Word(32); (* Размер одного программного заголовка *)
  Word(1); (* Количество программных заголовков *)
  Word(0); (* Размер заголовка секции (в исполнимом файле они не нужны) *)
  Word(0); (* Количество заголовков секций *)
  Word(0) (* Номер секции с таблицей строк (в исполнимом файле не нужны) *)
END WriteElfHeader;

PROCEDURE WriteProgramHeader;
BEGIN
  DWord(1); (* Вид данного сегмента - сегмент для загрузки *)
  DWord(54H); (* Смещение на начало данного сегмента = 84 *)
  DWord(08040054H); (* Виртуальный адрес первого байта в сегменте *)
  DWord(08040054H); (* Физический адрес - не используется !FIXME Проверить, нужен ли здесь 0 *)
  DWord(38); (* Сколько сегмент занимает в файле *)
  DWord(38); (* Сколько сегмент занимает в файле *)
  DWord(5); (* Флаги сегмента: 4 + 1 = чтение + исполнение *)
  DWord(1000H) (* Выравнивание для виртуального адреса и смещения в файле *)
END WriteProgramHeader;

PROCEDURE WriteTextSegment;
BEGIN
  Byte(0B9H); (* MOV ECX, DWORD ... *)
  DWord(08040054H + 34); (* Откуда брать строку *)

  Byte(0BAH); (* MOV EDX, DWORD ... *)
  DWord(04H); (* Длина строки *)

  Byte(0BBH); (* MOV EBX, DWORD ... *)
  DWord(01H); (* Куда писать: стандартное устройство вывода STDOUT *)

  Byte(0B8H); (* MOV EAX, DWORD ... *)
  DWord(04H); (* Системный вызов: write *)

  Byte(0CDH); (* Прерывание: INT *)
  Byte(080H); (* Номер прерывания *)

  Byte(0BBH); (* MOV EBX, DWORD ... *)
  DWord(01H); (* Код возврата (exit code) *)

  Byte(0B8H); (* MOV EAX, DWORD ... *)
  DWord(01H); (* Системный вызов: exit *)

  Byte(0CDH); (* Прерывание: INT *)
  Byte(080H); (* Номер прерывания *)

  Byte(ORD("H")); (* Строка *)
  Byte(ORD("i"));
  Byte(ORD("!"));
  Byte(0AH)
END WriteTextSegment;

PROCEDURE WriteElf;
BEGIN
  WriteElfHeader;
  WriteProgramHeader;
  WriteTextSegment
END WriteElf;

PROCEDURE WriteDummy*;
BEGIN
  F := Files.New(fname);
  IF F # NIL THEN
    Files.Set(r, F, 0);
    WriteElf;
    Files.Register(F);
    Files.Close(F);
    IF Chmod.MakeExecutable(fname) = 0 THEN END
  ELSE
    Out.String("Не могу создать файл ");
    Out.String(fname); Out.Ln
  END
END WriteDummy;

PROCEDURE MakeItem*(VAR x: Item; o: ST.Object);
BEGIN
  x.mode := o.class;
  x.type := o.type;
  x.val := o.val
END MakeItem;

PROCEDURE Call*(VAR x: Item);
BEGIN
  Out.String("Вызвана процедура ");
  Out.Int(x.val, 0); Out.Ln
END Call;

END Generator.
