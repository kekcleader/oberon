MODULE Chmod;
IMPORT SYSTEM;

PROCEDURE -AAIncludeChmodh* '#include "chmod/chmod.h"';

PROCEDURE -MakeExecutable*
  (path: ARRAY OF CHAR): INTEGER
  "MakeExecutable(path)";

END Chmod.
