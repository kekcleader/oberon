MODULE Chmod;
IMPORT SYSTEM;

PROCEDURE -AAIncludeChmodh* '#include "c_chmod.h"';

PROCEDURE -MakeExecutable*
  (path: ARRAY OF CHAR): INTEGER
  "MakeExecutable(path)";

END Chmod.
