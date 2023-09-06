import childProcess from "child_process";

import Key from "./Key";

interface Interpreter {
  key: Key | null;
  task: childProcess.ChildProcess;
}

export default Interpreter;
