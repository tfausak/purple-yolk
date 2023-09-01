import assert from "assert";
import childProcess from "child_process";
import path from "path";
import perfHooks from "perf_hooks";
import readline from "readline";
import vscode from "vscode";
import which from "which";

import my from "../package.json";

// https://hackage.haskell.org/package/hlint-3.6.1/docs/Language-Haskell-HLint.html#t:Idea
interface Idea {
  decl: string[];
  endColumn: number;
  endLine: number;
  file: string;
  from: string;
  hint: string;
  module: string[];
  note: string[];
  refactorings: string;
  severity: IdeaSeverity;
  startColumn: number;
  startLine: number;
  to: string | null;
}

// https://hackage.haskell.org/package/hlint-3.6.1/docs/Language-Haskell-HLint.html#t:Severity
enum IdeaSeverity {
  Ignore = "Ignore",
  Suggestion = "Suggestion",
  Warning = "Warning",
  Error = "Error",
}

interface Interpreter {
  key: Key | null;
  task: childProcess.ChildProcess;
}

type Key = string;

interface Message {
  doc: string;
  messageClass: string | null; // Used by GHC >= 9.4.
  reason: MessageReason | null;
  severity: MessageSeverity | null; // Used by GHC < 9.4.
  span: MessageSpan | null;
}

// https://downloads.haskell.org/ghc/9.6.2/docs/libraries/ghc-9.6.2/GHC-Driver-Flags.html#t:WarningFlag
type MessageReason = string;

// https://downloads.haskell.org/ghc/9.6.2/docs/libraries/ghc-9.6.2/GHC-Types-Error.html#t:Severity
enum MessageSeverity {
  SevDump = "SevDump",
  SevError = "SevError",
  SevFatal = "SevFatal",
  SevInfo = "SevInfo",
  SevInteractive = "SevInteractive",
  SevOutput = "SevOutput",
  SevWarning = "SevWarning",
}

// https://downloads.haskell.org/ghc/9.6.2/docs/libraries/ghc-9.6.2/GHC-Types-SrcLoc.html#t:SrcSpan
interface MessageSpan {
  endCol: number;
  endLine: number;
  file: string; // Can be `"<interactive>"`.
  startCol: number;
  startLine: number;
}

const DEFAULT_MESSAGE_SPAN: MessageSpan = {
  endCol: 1,
  endLine: 1,
  file: "<interactive>",
  startCol: 1,
  startLine: 1,
};

let INTERPRETER: Interpreter | null = null;

const CABAL_LANGUAGE_ID = "cabal";

const HASKELL_LANGUAGE_ID = "haskell";

const INTERPRETER_DISCOVER = "discover";

const INTERPRETER_CABAL = "cabal";

const INTERPRETER_STACK = "stack";

const INTERPRETER_GHCI = "ghci";

export function activate(context: vscode.ExtensionContext): void {
  const channel = vscode.window.createOutputChannel(my.displayName);
  const key = newKey();
  const start = perfHooks.performance.now();
  log(channel, key, `Activating ${my.name} version ${my.version} ...`);

  const interpreterCollection = vscode.languages.createDiagnosticCollection(
    my.name
  );
  const linterCollection = vscode.languages.createDiagnosticCollection(my.name);

  const status = vscode.languages.createLanguageStatusItem(
    my.name,
    HASKELL_LANGUAGE_ID
  );
  status.command = { command: `${my.name}.output.show`, title: "Show Output" };
  status.text = "Idle";
  status.name = my.displayName;

  context.subscriptions.push(
    vscode.commands.registerCommand(
      `${my.name}.${HASKELL_LANGUAGE_ID}.interpret`,
      () => commandHaskellInterpret(channel, status, interpreterCollection)
    )
  );

  context.subscriptions.push(
    vscode.commands.registerCommand(
      `${my.name}.${HASKELL_LANGUAGE_ID}.lint`,
      () => commandHaskellLint(channel, linterCollection)
    )
  );

  context.subscriptions.push(
    vscode.commands.registerCommand(`${my.name}.output.show`, () =>
      commandOutputShow(channel)
    )
  );

  vscode.workspace.onDidSaveTextDocument((document) => {
    switch (document.languageId) {
      case HASKELL_LANGUAGE_ID:
        reloadInterpreter(channel, status, interpreterCollection);

        const shouldLint: boolean | undefined = vscode.workspace
          .getConfiguration(my.name)
          .get(`${HASKELL_LANGUAGE_ID}.linter.onSave`);
        if (shouldLint) {
          commandHaskellLint(channel, linterCollection);
        }

        break;
    }
  });

  const languageIds = [CABAL_LANGUAGE_ID, HASKELL_LANGUAGE_ID];
  languageIds.forEach((languageId: string) => {
    vscode.languages.registerDocumentFormattingEditProvider(languageId, {
      provideDocumentFormattingEdits: (document, _, token) =>
        formatDocument(languageId, channel, document, token),
    });

    vscode.languages.registerDocumentRangeFormattingEditProvider(languageId, {
      provideDocumentRangeFormattingEdits: (document, range, _, token) =>
        formatDocumentRange(languageId, channel, document, range, token),
    });
  });

  commandHaskellInterpret(channel, status, interpreterCollection);

  const end = perfHooks.performance.now();
  const elapsed = ((end - start) / 1000).toFixed(3);
  log(channel, key, `Successfully activated in ${elapsed} seconds.`);
}

function commandHaskellInterpret(
  channel: vscode.OutputChannel,
  status: vscode.LanguageStatusItem,
  collection: vscode.DiagnosticCollection
): void {
  const document = vscode.window.activeTextEditor?.document;
  if (!document) {
    return;
  }

  startInterpreter(channel, status, collection, document);
}

function commandHaskellLint(
  channel: vscode.OutputChannel,
  collection: vscode.DiagnosticCollection
): void {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== HASKELL_LANGUAGE_ID) {
    return;
  }

  vscode.window.withProgress(
    {
      cancellable: true,
      location: vscode.ProgressLocation.Window,
      title: `Linting`,
    },
    async (progress, token) => {
      progress.report({
        message: vscode.workspace.asRelativePath(document.uri),
      });
      const diagnostics = await lintHaskell(channel, document, token);
      collection.set(document.uri, diagnostics);
    }
  );
}

function commandOutputShow(channel: vscode.OutputChannel): void {
  channel.show(true);
}

function formatDocument(
  languageId: string,
  channel: vscode.OutputChannel,
  document: vscode.TextDocument,
  token: vscode.CancellationToken
): Promise<vscode.TextEdit[]> {
  const range: vscode.Range = document.validateRange(
    new vscode.Range(
      new vscode.Position(0, 0),
      new vscode.Position(Infinity, Infinity)
    )
  );
  return formatDocumentRange(languageId, channel, document, range, token);
}

function expandTemplate(
  template: string,
  replacements: { [key: string]: string }
): string {
  return template.replace(/\$\{(.*?)\}/, (_, key) => {
    const value = replacements[key];
    if (typeof value === "undefined") {
      throw `unknown variable: ${key}`;
    }
    return value;
  });
}

async function formatDocumentRange(
  languageId: string,
  channel: vscode.OutputChannel,
  document: vscode.TextDocument,
  range: vscode.Range,
  token: vscode.CancellationToken
): Promise<vscode.TextEdit[]> {
  const key = newKey();
  const start = perfHooks.performance.now();
  const file = vscode.workspace.asRelativePath(document.uri);
  log(channel, key, `Formatting ${file} using language ${languageId} ...`);

  const folder = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!folder) {
    log(channel, key, "Error: Missing workspace folder!");
    return [];
  }

  const template: string | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${languageId}.formatter.command`);
  if (!template) {
    log(channel, key, "Error: Missing formatter command!");
    return [];
  }

  const command = expandTemplate(template, { file });
  const cwd = folder.uri.path;
  log(
    channel,
    key,
    `Running ${JSON.stringify(command)} in ${JSON.stringify(cwd)} ...`
  );
  const task: childProcess.ChildProcess = childProcess.spawn(command, {
    cwd,
    shell: true,
  });

  assert.ok(task.stderr);
  readline.createInterface(task.stderr).on("line", (line) => {
    log(channel, key, `[stderr] ${line}`);
  });

  let output = "";
  task.stdout?.on("data", (data) => (output += data));

  token.onCancellationRequested(() => {
    log(channel, key, "Cancelling ...");
    task.kill();
  });

  task.stdin?.end(document.getText(range));

  const code: number = await new Promise((resolve) =>
    task.on("close", resolve)
  );
  if (code !== 0) {
    log(channel, key, `Error: Formatter exited with ${code}!`);
    if (!task.killed) {
      vscode.window.showErrorMessage(`Failed to format ${file}!`);
    }
    return [];
  }

  const end = perfHooks.performance.now();
  const elapsed = ((end - start) / 1000).toFixed(3);
  log(channel, key, `Successfully formatted in ${elapsed} seconds.`);
  return [new vscode.TextEdit(range, output)];
}

function ideaSeverityToDiagnostic(
  severity: IdeaSeverity
): vscode.DiagnosticSeverity {
  switch (severity) {
    case IdeaSeverity.Ignore:
      return vscode.DiagnosticSeverity.Hint;
    default:
      return vscode.DiagnosticSeverity.Information;
  }
}

function ideaToDiagnostic(idea: Idea): vscode.Diagnostic {
  const range = ideaToRange(idea);
  const message = ideaToMessage(idea);
  const diagnosticSeverity = ideaSeverityToDiagnostic(idea.severity);
  const diagnostic = new vscode.Diagnostic(range, message, diagnosticSeverity);
  diagnostic.source = my.name;
  return diagnostic;
}

function ideaToMessage(idea: Idea): string {
  const lines: string[] = [idea.hint];
  if (idea.to) {
    lines.push(`Why not: ${idea.to}`);
  }
  for (const note of idea.note) {
    lines.push(`Note: ${note}`);
  }
  return lines.join("\n");
}

function ideaToRange(idea: Idea): vscode.Range {
  return new vscode.Range(
    new vscode.Position(idea.startLine - 1, idea.startColumn - 1),
    new vscode.Position(idea.endLine - 1, idea.endColumn - 1)
  );
}

async function lintHaskell(
  channel: vscode.OutputChannel,
  document: vscode.TextDocument,
  token: vscode.CancellationToken
): Promise<vscode.Diagnostic[]> {
  const key = newKey();
  const start = perfHooks.performance.now();
  const file = vscode.workspace.asRelativePath(document.uri);
  log(channel, key, `Linting ${file} ...`);

  const folder = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!folder) {
    log(channel, key, "Error: Missing workspace folder!");
    return [];
  }

  const template: string | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${HASKELL_LANGUAGE_ID}.linter.command`);
  if (!template) {
    log(channel, key, "Error: Missing linter command!");
    return [];
  }

  const command = expandTemplate(template, { file });
  const cwd = folder.uri.path;
  log(
    channel,
    key,
    `Running ${JSON.stringify(command)} in ${JSON.stringify(cwd)} ...`
  );
  const task: childProcess.ChildProcess = childProcess.spawn(command, {
    cwd,
    shell: true,
  });

  assert.ok(task.stderr);
  readline.createInterface(task.stderr).on("line", (line) => {
    log(channel, key, `[stderr] ${line}`);
  });

  let output = "";
  task.stdout?.on("data", (data) => (output += data));

  token.onCancellationRequested(() => {
    log(channel, key, "Cancelling ...");
    task.kill();
  });

  task.stdin?.end(document.getText());

  const code: number = await new Promise((resolve) =>
    task.on("close", resolve)
  );
  if (code !== 0) {
    log(channel, key, `Error: Linter exited with ${code}!`);
    if (!task.killed) {
      vscode.window.showErrorMessage(`Failed to lint ${file}!`);
    }
    return [];
  }

  let ideas: Idea[];
  try {
    ideas = JSON.parse(output);
  } catch (error) {
    log(channel, key, `Error: ${error}`);
    vscode.window.showErrorMessage(`Failed to lint ${file}!`);
    return [];
  }

  const end = perfHooks.performance.now();
  const elapsed = ((end - start) / 1000).toFixed(3);
  log(channel, key, `Successfully linted in ${elapsed} seconds.`);
  return ideas.map(ideaToDiagnostic);
}

function log(channel: vscode.OutputChannel, key: Key, message: string): void {
  channel.appendLine(`${new Date().toISOString()} [${key}] ${message}`);
}

function messageSeverityToDiagnostic(
  severity: MessageSeverity
): vscode.DiagnosticSeverity {
  switch (severity) {
    case MessageSeverity.SevError:
      return vscode.DiagnosticSeverity.Error;
    case MessageSeverity.SevFatal:
      return vscode.DiagnosticSeverity.Error;
    case MessageSeverity.SevWarning:
      return vscode.DiagnosticSeverity.Warning;
    default:
      return vscode.DiagnosticSeverity.Information;
  }
}

function messageClassToDiagnostic(
  messageClass: string
): vscode.DiagnosticSeverity {
  const severities = new Set(Object.values(MessageSeverity));
  for (const klass of messageClass.split(/ +/)) {
    const severity = klass as MessageSeverity;
    if (severities.has(severity)) {
      return messageSeverityToDiagnostic(severity);
    }
  }
  return vscode.DiagnosticSeverity.Information;
}

function messageSpanToRange(span: MessageSpan): vscode.Range {
  return new vscode.Range(
    new vscode.Position(span.startLine - 1, span.startCol - 1),
    new vscode.Position(span.endLine - 1, span.endCol - 1)
  );
}

function messageToDiagnostic(message: Message): vscode.Diagnostic {
  const range = messageSpanToRange(message.span || DEFAULT_MESSAGE_SPAN);
  let severity = vscode.DiagnosticSeverity.Information;
  if (message.severity) {
    severity = messageSeverityToDiagnostic(message.severity);
  } else if (message.messageClass) {
    severity = messageClassToDiagnostic(message.messageClass);
  }
  const diagnostic = new vscode.Diagnostic(range, message.doc, severity);
  if (message.reason) {
    diagnostic.code = message.reason;
  }
  diagnostic.source = my.name;
  return diagnostic;
}

function newKey(): Key {
  return Math.floor(Math.random() * (0xffff + 1))
    .toString(16)
    .padStart(4, "0");
}

async function reloadInterpreter(
  channel: vscode.OutputChannel,
  status: vscode.LanguageStatusItem,
  collection: vscode.DiagnosticCollection
): Promise<void> {
  const key = newKey();
  const start = perfHooks.performance.now();
  log(channel, key, "Reloading interpreter ...");

  if (!INTERPRETER) {
    log(channel, key, "Error: Missing interpreter!");
    return;
  }

  if (INTERPRETER.key) {
    log(channel, key, `Ignoring because ${INTERPRETER.key} is running.`);
    return;
  }

  INTERPRETER.key = key;

  status.busy = true;
  status.detail = "";
  status.text = "Loading";

  const document = vscode.window.activeTextEditor?.document;
  if (document) {
    const folder = vscode.workspace.getWorkspaceFolder(document.uri);
    if (folder) {
      collection.delete(folder.uri);
    }
  }

  const input = ":reload";
  log(channel, key, `[stdin] ${input}`);
  INTERPRETER.task.stdin?.write(`${input}\n`);

  while (INTERPRETER.key === key) {
    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  const end = perfHooks.performance.now();
  const elapsed = ((end - start) / 1000).toFixed(3);
  log(channel, key, `Finished reloading in ${elapsed} seconds.`);
}

async function startInterpreter(
  channel: vscode.OutputChannel,
  status: vscode.LanguageStatusItem,
  collection: vscode.DiagnosticCollection,
  document: vscode.TextDocument
): Promise<void> {
  const key = newKey();
  const start = perfHooks.performance.now();
  log(channel, key, "Starting interpreter ...");

  const folder = vscode.workspace.getWorkspaceFolder(document.uri);
  if (!folder) {
    log(channel, key, "Error: Missing workspace folder!");
    return;
  }

  let interpreter: string | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${HASKELL_LANGUAGE_ID}.interpreter.command`);
  if (interpreter === INTERPRETER_DISCOVER) {
    const cabal = await which("cabal", { nothrow: true });
    const [cabalProject] = await vscode.workspace.findFiles(
      "cabal.project",
      undefined,
      1
    );

    const stack = await which("stack", { nothrow: true });
    const [stackYaml] = await vscode.workspace.findFiles(
      "stack.yaml",
      undefined,
      1
    );

    const ghci = await which("ghci", { nothrow: true });

    if (cabal && !stack) {
      // If the user only has Cabal available, then use Cabal.
      interpreter = INTERPRETER_CABAL;
    } else if (!cabal && stack) {
      // If the user only has Stack available, then use Stack.
      interpreter = INTERPRETER_STACK;
    } else if (cabal && stack) {
      if (!cabalProject && stackYaml) {
        // If the user has both Cabal and Stack installed, but they only have a
        // Stack project file, then use Stack.
        interpreter = INTERPRETER_STACK;
      } else {
        // Otherwise use Cabal.
        interpreter = INTERPRETER_CABAL;
      }
    } else if (ghci) {
      // If the user has neither Cabal nor Stack installed, then attempt to use
      // GHCi.
      interpreter = INTERPRETER_GHCI;
    }
  }
  let template: string | undefined = undefined;
  switch (interpreter) {
    case INTERPRETER_CABAL:
      template = "cabal repl --repl-options -ddump-json";
      break;
    case INTERPRETER_STACK:
      template = "stack ghci --ghci-options -ddump-json";
      break;
    case INTERPRETER_GHCI:
      template = "ghci -ddump-json ${file}";
      break;
    case "custom":
      template = vscode.workspace
        .getConfiguration(my.name)
        .get(`${HASKELL_LANGUAGE_ID}.interpreter.custom`);
      break;
    default:
      break;
  }

  if (!template) {
    log(channel, key, "Error: Missing interpreter command!");
    return;
  }

  const file = vscode.workspace.asRelativePath(document.uri);
  const command = expandTemplate(template, { file });

  status.busy = true;
  status.detail = "";
  status.severity = vscode.LanguageStatusSeverity.Information;
  status.text = "Starting";

  if (INTERPRETER) {
    log(channel, key, `Stopping interpreter ${INTERPRETER.task.pid} ...`);
    INTERPRETER.task.kill();
    INTERPRETER = null;
    collection.clear();
  }

  const cwd = folder.uri.path;
  log(
    channel,
    key,
    `Running ${JSON.stringify(command)} in ${JSON.stringify(cwd)} ...`
  );
  const task: childProcess.ChildProcess = childProcess.spawn(command, {
    cwd,
    shell: true,
  });
  INTERPRETER = { key, task };

  task.on("close", (code) => {
    log(channel, key, `Error: Interpreter exited with ${code}!`);
    if (code !== null) {
      status.busy = false;
      status.detail = "";
      status.text = "Exited";
      status.severity = vscode.LanguageStatusSeverity.Error;
    }
  });

  assert.ok(task.stderr);
  readline.createInterface(task.stderr).on("line", (line) => {
    log(channel, key, `[stderr] ${line}`);
  });

  const prompt = `{- ${my.name} ${my.version} ${key} -}`;
  const input = `:set prompt "${prompt}\\n"`;
  log(channel, key, `[stdin] ${input}`);
  task.stdin?.write(`${input}\n`);

  await new Promise<void>((resolve) => {
    assert.ok(task.stdout);
    readline.createInterface(task.stdout).on("line", (line) => {
      let shouldLog: boolean = true;

      if (line.includes(prompt)) {
        if (INTERPRETER?.key) {
          INTERPRETER.key = null;
        }
        resolve();
        status.busy = false;
        status.detail = "";
        status.text = "Idle";
        shouldLog = false;
      }

      let message: Message | null = null;
      try {
        message = JSON.parse(line);
      } catch (error) {
        if (!(error instanceof SyntaxError)) {
          throw error;
        }
      }

      if (message) {
        const pattern = /^\[ *(\d+) of (\d+)\] Compiling ([^ ]+) +\( ([^,]+)/;
        const match = message.doc.match(pattern);
        if (match) {
          status.detail = `${match[1]} of ${match[2]}: ${match[3]}`;

          assert.ok(match[4]);
          const uri = vscode.Uri.joinPath(folder.uri, match[4]);
          collection.delete(uri);

          shouldLog = false;
        } else {
          let uri: vscode.Uri | null = null;
          if (message.span) {
            if (message.span.file !== DEFAULT_MESSAGE_SPAN.file) {
              if (path.isAbsolute(message.span.file)) {
                uri = vscode.Uri.file(message.span.file);
              } else {
                uri = vscode.Uri.joinPath(folder.uri, message.span.file);
              }
            }
          } else {
            uri = folder.uri;
          }

          if (uri) {
            const diagnostic = messageToDiagnostic(message);
            collection.set(uri, (collection.get(uri) || []).concat(diagnostic));

            shouldLog = false;
          }
        }
      }

      if (shouldLog) {
        log(channel, INTERPRETER?.key || "0000", `[stdout] ${line}`);
      }
    });
  });

  const end = perfHooks.performance.now();
  const elapsed = ((end - start) / 1000).toFixed(3);
  log(channel, key, `Successfully started in ${elapsed} seconds.`);
}
