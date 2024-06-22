import assert from "assert";
import childProcess from "child_process";
import path from "path";
import perfHooks from "perf_hooks";
import readline from "readline";
import vscode from "vscode";
import which from "which";
import { Utils } from "vscode-uri";

import CabalFormatterMode from "./type/CabalFormatterMode";
import HaskellFormatterMode from "./type/HaskellFormatterMode";
import HaskellLinterMode from "./type/HaskellLinterMode";
import Idea from "./type/Idea";
import IdeaSeverity from "./type/IdeaSeverity";
import Interpreter from "./type/Interpreter";
import InterpreterMode from "./type/InterpreterMode";
import Key from "./type/Key";
import LanguageId from "./type/LanguageId";
import Message from "./type/Message";
import MessageSeverity from "./type/MessageSeverity";
import MessageSpan from "./type/MessageSpan";
import Template from "./type/Template";

import my from "../package.json";

const DEFAULT_MESSAGE_SPAN: MessageSpan = {
  endCol: 1,
  endLine: 1,
  file: "<interactive>",
  startCol: 1,
  startLine: 1,
};

let INTERPRETER: Interpreter | null = null;

let INTERPRETER_TEMPLATE: Template | undefined = undefined;

let HASKELL_FORMATTER_TEMPLATE: Template | undefined = undefined;

let HASKELL_LINTER_TEMPLATE: Template | undefined = undefined;

let CABAL_FORMATTER_TEMPLATE: Template | undefined = undefined;

// https://hackage.haskell.org/package/ghc-9.8.2/docs/GHC-Driver-Flags.html#v:warnFlagNames
const GHC_WARNING_FLAGS: { [k: string]: string } = {
  Opt_WarnAllMissedSpecs: "all-missed-specialisations",
  Opt_WarnAlternativeLayoutRuleTransitional: "alternative-layout-rule-transitional",
  Opt_WarnAmbiguousFields: "ambiguous-fields",
  Opt_WarnAutoOrphans: "auto-orphans",
  Opt_WarnCompatUnqualifiedImports: "compat-unqualified-imports",
  Opt_WarnCPPUndef: "cpp-undef",
  Opt_WarnDeferredOutOfScopeVariables: "deferred-out-of-scope-variables",
  Opt_WarnDeferredTypeErrors: "deferred-type-errors",
  Opt_WarnDeprecatedFlags: "deprecated-flags",
  Opt_WarnDerivingDefaults: "deriving-defaults",
  Opt_WarnDerivingTypeable: "deriving-typeable",
  Opt_WarnDodgyExports: "dodgy-exports",
  Opt_WarnDodgyForeignImports: "dodgy-foreign-imports",
  Opt_WarnDodgyImports: "dodgy-imports",
  Opt_WarnDuplicateConstraints: "duplicate-constraints",
  Opt_WarnDuplicateExports: "duplicate-exports",
  Opt_WarnEmptyEnumerations: "empty-enumerations",
  Opt_WarnForallIdentifier: "forall-identifier",
  Opt_WarnGADTMonoLocalBinds: "gadt-mono-local-binds",
  Opt_WarnHiShadows: "hi-shadowing",
  Opt_WarnIdentities: "identities",
  Opt_WarnImplicitKindVars: "implicit-kind-vars",
  Opt_WarnImplicitLift: "implicit-lift",
  Opt_WarnImplicitPrelude: "implicit-prelude",
  Opt_WarnImplicitRhsQuantification: "implicit-rhs-quantification",
  Opt_WarnInaccessibleCode: "inaccessible-code",
  Opt_WarnIncompleteExportWarnings: "incomplete-export-warnings",
  Opt_WarnIncompletePatterns: "incomplete-patterns",
  Opt_WarnIncompletePatternsRecUpd: "incomplete-record-updates",
  Opt_WarnIncompleteUniPatterns: "incomplete-uni-patterns",
  Opt_WarnInconsistentFlags: "inconsistent-flags",
  Opt_WarnInferredSafeImports: "inferred-safe-imports",
  Opt_WarnInlineRuleShadowing: "inline-rule-shadowing",
  Opt_WarnInvalidHaddock: "invalid-haddock",
  Opt_WarnLoopySuperclassSolve: "loopy-superclass-solve",
  Opt_WarnMisplacedPragmas: "misplaced-pragmas",
  Opt_WarnMissedExtraSharedLib: "missed-extra-shared-lib",
  Opt_WarnMissedSpecs: "missed-specialisations",
  Opt_WarnMissingDerivingStrategies: "missing-deriving-strategies",
  Opt_WarnMissingExportedPatternSynonymSignatures: "missing-exported-pattern-synonym-signatures",
  Opt_WarnMissingExportedSignatures: "missing-exported-signatures",
  Opt_WarnMissingExportList: "missing-export-lists",
  Opt_WarnMissingFields: "missing-fields",
  Opt_WarnMissingHomeModules: "missing-home-modules",
  Opt_WarnMissingImportList: "missing-import-lists",
  Opt_WarnMissingKindSignatures: "missing-kind-signatures",
  Opt_WarnMissingLocalSignatures: "missing-local-signatures",
  Opt_WarnMissingMethods: "missing-methods",
  Opt_WarnMissingMonadFailInstances: "missing-monadfail-instances",
  Opt_WarnMissingPatternSynonymSignatures: "missing-pattern-synonym-signatures",
  Opt_WarnMissingPolyKindSignatures: "missing-poly-kind-signatures",
  Opt_WarnMissingRoleAnnotations: "missing-role-annotations",
  Opt_WarnMissingSafeHaskellMode: "missing-safe-haskell-mode",
  Opt_WarnMissingSignatures: "missing-signatures",
  Opt_WarnMonomorphism: "monomorphism-restriction",
  Opt_WarnNameShadowing: "name-shadowing",
  Opt_WarnNonCanonicalMonadFailInstances: "noncanonical-monadfail-instances",
  Opt_WarnNonCanonicalMonadInstances: "noncanonical-monad-instances",
  Opt_WarnNonCanonicalMonoidInstances: "noncanonical-monoid-instances",
  Opt_WarnOperatorWhitespace: "operator-whitespace",
  Opt_WarnOperatorWhitespaceExtConflict: "operator-whitespace-ext-conflict",
  Opt_WarnOrphans: "orphans",
  Opt_WarnOverflowedLiterals: "overflowed-literals",
  Opt_WarnOverlappingPatterns: "overlapping-patterns",
  Opt_WarnPartialFields: "partial-fields",
  Opt_WarnPartialTypeSignatures: "partial-type-signatures",
  Opt_WarnPrepositiveQualifiedModule: "prepositive-qualified-module",
  Opt_WarnRedundantBangPatterns: "redundant-bang-patterns",
  Opt_WarnRedundantConstraints: "redundant-constraints",
  Opt_WarnRedundantRecordWildcards: "redundant-record-wildcards",
  Opt_WarnRedundantStrictnessFlags: "redundant-strictness-flags",
  Opt_WarnSafe: "safe",
  Opt_WarnSemigroup: "semigroup",
  Opt_WarnSimplifiableClassConstraints: "simplifiable-class-constraints",
  Opt_WarnSpaceAfterBang: "missing-space-after-bang",
  Opt_WarnStarBinder: "star-binder",
  Opt_WarnStarIsType: "star-is-type",
  Opt_WarnTabs: "tabs",
  Opt_WarnTermVariableCapture: "term-variable-capture",
  Opt_WarnTrustworthySafe: "trustworthy-safe",
  Opt_WarnTypeDefaults: "type-defaults",
  Opt_WarnTypedHoles: "typed-holes",
  Opt_WarnTypeEqualityOutOfScope: "type-equality-out-of-scope",
  Opt_WarnTypeEqualityRequiresOperators: "type-equality-requires-operators",
  Opt_WarnUnbangedStrictPatterns: "unbanged-strict-patterns",
  Opt_WarnUnicodeBidirectionalFormatCharacters: "unicode-bidirectional-format-characters",
  Opt_WarnUnrecognisedPragmas: "unrecognised-pragmas",
  Opt_WarnUnrecognisedWarningFlags: "unrecognised-warning-flags",
  Opt_WarnUnsafe: "unsafe",
  Opt_WarnUnsupportedCallingConventions: "unsupported-calling-conventions",
  Opt_WarnUnsupportedLlvmVersion: "unsupported-llvm-version",
  Opt_WarnUntickedPromotedConstructors: "unticked-promoted-constructors",
  Opt_WarnUnusedDoBind: "unused-do-bind",
  Opt_WarnUnusedForalls: "unused-foralls",
  Opt_WarnUnusedImports: "unused-imports",
  Opt_WarnUnusedLocalBinds: "unused-local-binds",
  Opt_WarnUnusedMatches: "unused-matches",
  Opt_WarnUnusedPackages: "unused-packages",
  Opt_WarnUnusedPatternBinds: "unused-pattern-binds",
  Opt_WarnUnusedRecordWildcards: "unused-record-wildcards",
  Opt_WarnUnusedTopBinds: "unused-top-binds",
  Opt_WarnUnusedTypePatterns: "unused-type-patterns",
  Opt_WarnWrongDoBind: "wrong-do-bind",
};

// GHC warnings that should get an "unnecessary" tag.
const UNNECESSARY_WARNINGS = new Set([
  "Opt_WarnDuplicateConstraints",
  "Opt_WarnDuplicateExports",
  "Opt_WarnRedundantBangPatterns",
  "Opt_WarnRedundantConstraints",
  "Opt_WarnRedundantRecordWildcards",
  "Opt_WarnRedundantStrictnessFlags",
  "Opt_WarnUnusedDoBind",
  "Opt_WarnUnusedForalls",
  "Opt_WarnUnusedImports",
  "Opt_WarnUnusedLocalBinds",
  "Opt_WarnUnusedMatches",
  "Opt_WarnUnusedPackages",
  "Opt_WarnUnusedPatternBinds",
  "Opt_WarnUnusedRecordWildcards",
  "Opt_WarnUnusedTopBinds",
  "Opt_WarnUnusedTypePatterns",
]);

// GHC warnings that should get a "deprecated" tag.
const DEPRECATED_WARNINGS = new Set([
  "GHC-15328", // WarningWithCategory deprecations
  "GHC-63394", // WarningWithCategory x-partial
  "Opt_WarnDeprecatedFlags",
]);

function discoverInterpreterMode(
  cabal: string | undefined,
  cabalProject: vscode.Uri | undefined, // cabal.project
  cabalPackage: vscode.Uri | undefined, // *.cabal
  ghci: string | undefined,
  stack: string | undefined,
  stackProject: vscode.Uri | undefined, // stack.yaml
  stackPackage: vscode.Uri | undefined // package.yaml
): InterpreterMode {
  // If the user has GHCi installed and there are no Cabal or Stack files, then
  // use GHCi.
  if (ghci && !cabalProject && !cabalPackage && !stackProject && !stackPackage) {
    return InterpreterMode.Ghci;
  }

  if (cabal && !stack) {
    // If the user only has Cabal available, then use Cabal.
    return InterpreterMode.Cabal;
  }

  if (!cabal && stack) {
    // If the user only has Stack available, then use Stack.
    return InterpreterMode.Stack;
  }

  if (cabal && stack) {
    if (!cabalProject && stackProject) {
      // If the user has both Cabal and Stack installed, but they only have a
      // Stack project file, then use Stack.
      return InterpreterMode.Stack;
    }

    // Otherwise use Cabal.
    return InterpreterMode.Cabal;
  }

  if (ghci) {
    // If the user has neither Cabal nor Stack installed, then attempt to use
    // GHCi.
    return InterpreterMode.Ghci;
  }

  return InterpreterMode.Discover;
}

async function setInterpreterTemplate(
  channel: vscode.OutputChannel
): Promise<void> {
  const key = newKey();
  log(channel, key, "Getting Haskell interpreter ...");

  let mode: InterpreterMode | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.interpreter.mode`);
  log(channel, key, `Requested Haskell interpreter mode is ${mode}`);

  const custom: Template | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.interpreter.command`);

  if (mode === InterpreterMode.Discover) {
    if (custom) {
      mode = InterpreterMode.Custom;
    } else {
      const [cabal, [cabalProject], [cabalPackage], stack, [stackProject], [stackPackage], ghci] =
        await Promise.all([
          which("cabal", { nothrow: true }),
          vscode.workspace.findFiles("cabal.project", undefined, 1),
          vscode.workspace.findFiles("*.cabal", undefined, 1),
          which("stack", { nothrow: true }),
          vscode.workspace.findFiles("stack.yaml", undefined, 1),
          vscode.workspace.findFiles("package.yaml", undefined, 1),
          which("ghci", { nothrow: true }),
        ]);

      mode = discoverInterpreterMode(
        cabal,
        cabalProject,
        cabalPackage,
        ghci,
        stack,
        stackProject,
        stackPackage
      );
    }
  }
  log(channel, key, `Actual Haskell interpreter mode is ${mode}`);

  switch (mode) {
    case InterpreterMode.Cabal:
      INTERPRETER_TEMPLATE = "cabal repl --repl-options -ddump-json";
      break;
    case InterpreterMode.Stack:
      INTERPRETER_TEMPLATE = "stack ghci --ghci-options -ddump-json";
      break;
    case InterpreterMode.Ghci:
      INTERPRETER_TEMPLATE = "ghci -ddump-json ${file}";
      break;
    case InterpreterMode.Custom:
      INTERPRETER_TEMPLATE = custom;
      break;
    default:
      INTERPRETER_TEMPLATE = undefined;
      break;
  }
}

function discoverHaskellFormatterMode(
  fourmolu: string | undefined,
  fourmoluConfig: vscode.Uri | undefined,
  ormolu: string | undefined,
  ormoluConfig: vscode.Uri | undefined
): HaskellFormatterMode {
  if (fourmolu && !ormolu) {
    // If the user only has Fourmolu available, then use Fourmolu.
    return HaskellFormatterMode.Fourmolu;
  }

  if (!fourmolu && ormolu) {
    // If the user only has Ormolu available, then use Ormolu.
    return HaskellFormatterMode.Ormolu;
  }

  if (fourmolu && ormolu) {
    if (fourmoluConfig && !ormoluConfig) {
      // If the user has both Fourmolu and Ormolu installed, but they only
      // have a Fourmolu config file, then use Fourmolu.
      return HaskellFormatterMode.Fourmolu;
    }

    // Otherwise use Ormolu.
    return HaskellFormatterMode.Ormolu;
  }

  return HaskellFormatterMode.Discover;
}

async function setHaskellFormatterTemplate(
  channel: vscode.OutputChannel
): Promise<void> {
  const key = newKey();
  log(channel, key, "Getting Haskell formatter ...");

  let mode: HaskellFormatterMode | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.formatter.mode`);
  log(channel, key, `Requested Haskell formatter mode is ${mode}`);

  const custom: Template | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.formatter.command`);

  if (mode === HaskellFormatterMode.Discover) {
    if (custom) {
      mode = HaskellFormatterMode.Custom;
    } else {
      const [fourmolu, [fourmoluConfig], ormolu, [ormoluConfig]] =
        await Promise.all([
          which("fourmolu", { nothrow: true }),
          vscode.workspace.findFiles("fourmolu.yaml", undefined, 1),
          which("ormolu", { nothrow: true }),
          vscode.workspace.findFiles(".ormolu", undefined, 1),
        ]);

      mode = discoverHaskellFormatterMode(
        fourmolu,
        fourmoluConfig,
        ormolu,
        ormoluConfig
      );
    }
  }
  log(channel, key, `Actual Haskell formatter mode is ${mode}`);

  switch (mode) {
    case HaskellFormatterMode.Fourmolu:
      HASKELL_FORMATTER_TEMPLATE = "fourmolu --stdin-input-file ${file}";
      break;
    case HaskellFormatterMode.Ormolu:
      HASKELL_FORMATTER_TEMPLATE = "ormolu --stdin-input-file ${file}";
      break;
    case HaskellFormatterMode.Custom:
      HASKELL_FORMATTER_TEMPLATE = custom;
      break;
    default:
      HASKELL_FORMATTER_TEMPLATE = undefined;
      break;
  }
}

function discoverHaskellLinterMode(
  hlint: string | undefined
): HaskellLinterMode {
  if (hlint) {
    return HaskellLinterMode.Hlint;
  }

  return HaskellLinterMode.Discover;
}

async function setHaskellLinterTemplate(
  channel: vscode.OutputChannel
): Promise<void> {
  const key = newKey();
  log(channel, key, "Getting Haskell linter ...");

  let mode: HaskellLinterMode | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.linter.mode`);
  log(channel, key, `Requested Haskell linter mode is ${mode}`);

  const custom: Template | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Haskell}.linter.command`);

  if (mode === HaskellLinterMode.Discover) {
    if (custom) {
      mode = HaskellLinterMode.Custom;
    } else {
      const hlint = await which("hlint", { nothrow: true });

      mode = discoverHaskellLinterMode(hlint);
    }
  }
  log(channel, key, `Actual Haskell linter mode is ${mode}`);

  switch (mode) {
    case HaskellLinterMode.Hlint:
      HASKELL_LINTER_TEMPLATE = "hlint --json --no-exit-code -";
      break;
    case HaskellLinterMode.Custom:
      HASKELL_LINTER_TEMPLATE = custom;
      break;
    default:
      HASKELL_LINTER_TEMPLATE = undefined;
      break;
  }
}

function discoverCabalFormatterMode(
  cabalFmt: string | undefined,
  gild: string | undefined
): CabalFormatterMode {
  if (gild) {
    return CabalFormatterMode.Gild;
  }

  if (cabalFmt) {
    return CabalFormatterMode.CabalFmt;
  }

  return CabalFormatterMode.Discover;
}

async function setCabalFormatterTemplate(
  channel: vscode.OutputChannel
): Promise<void> {
  const key = newKey();
  log(channel, key, "Getting Cabal formatter ...");

  let mode: CabalFormatterMode | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Cabal}.formatter.mode`);
  log(channel, key, `Requested Cabal formatter mode is ${mode}`);

  const custom: Template | undefined = vscode.workspace
    .getConfiguration(my.name)
    .get(`${LanguageId.Cabal}.formatter.command`);

  if (mode === CabalFormatterMode.Discover) {
    if (custom) {
      mode = CabalFormatterMode.Custom;
    } else {
      const [cabalFmt, gild] =
        await Promise.all([
          which("cabal-fmt", { nothrow: true }),
          which("cabal-gild", { nothrow: true }),
        ]);

      mode = discoverCabalFormatterMode(cabalFmt, gild);
    }
  }
  log(channel, key, `Actual Cabal formatter mode is ${mode}`);

  switch (mode) {
    case CabalFormatterMode.CabalFmt:
      CABAL_FORMATTER_TEMPLATE = "cabal-fmt --no-cabal-file --no-tabular";
      break;
    case CabalFormatterMode.Gild:
      CABAL_FORMATTER_TEMPLATE = "cabal-gild --stdin ${file}";
      break;
    case CabalFormatterMode.Custom:
      CABAL_FORMATTER_TEMPLATE = custom;
      break;
    default:
      CABAL_FORMATTER_TEMPLATE = undefined;
      break;
  }
}

function updateStatus(
  status: vscode.LanguageStatusItem,
  busy: boolean,
  severity: vscode.LanguageStatusSeverity,
  text: string,
) {
  status.busy = busy;
  status.severity = severity;
  status.text = text;
}

export async function activate(
  context: vscode.ExtensionContext
): Promise<void> {
  const document = vscode.window.activeTextEditor?.document;

  const channel = vscode.window.createOutputChannel(my.displayName);
  const key = newKey();
  const start = perfHooks.performance.now();
  log(channel, key, `Activating ${my.name} version ${my.version} ...`);

  const collections = {
    ghc: vscode.languages.createDiagnosticCollection("ghc"),
    hlint: vscode.languages.createDiagnosticCollection("hlint"),
  };

  const status = vscode.languages.createLanguageStatusItem(
    my.name,
    LanguageId.Haskell
  );
  status.command = { command: `${my.name}.output.show`, title: "Show Output" };
  status.name = my.displayName;
  updateStatus(status, false, vscode.LanguageStatusSeverity.Information, "Idle");

  context.subscriptions.push(
    vscode.commands.registerCommand(
      `${my.name}.${LanguageId.Haskell}.interpret`,
      () => commandHaskellInterpret(channel, status, collections.ghc)
    )
  );

  context.subscriptions.push(
    vscode.commands.registerCommand(
      `${my.name}.${LanguageId.Haskell}.lint`,
      () => commandHaskellLint(channel, collections.hlint)
    )
  );

  context.subscriptions.push(
    vscode.commands.registerCommand(`${my.name}.output.show`, () =>
      commandOutputShow(channel)
    )
  );

  vscode.workspace.onDidSaveTextDocument((document) => {
    switch (document.languageId) {
      case LanguageId.Haskell:
        reloadInterpreter(channel, status, collections.ghc);

        const shouldLint: boolean | undefined = vscode.workspace
          .getConfiguration(my.name)
          .get(`${document.languageId}.linter.onSave`);
        if (shouldLint) {
          commandHaskellLint(channel, collections.hlint);
        }

        break;
    }
  });

  const languageIds = [LanguageId.Cabal, LanguageId.Haskell];
  languageIds.forEach((languageId: LanguageId) => {
    vscode.languages.registerDocumentFormattingEditProvider(languageId, {
      provideDocumentFormattingEdits: (document, _, token) =>
        formatDocument(languageId, channel, document, token),
    });

    vscode.languages.registerDocumentRangeFormattingEditProvider(languageId, {
      provideDocumentRangeFormattingEdits: (document, range, _, token) =>
        formatDocumentRange(languageId, channel, document, range, token),
    });
  });

  await Promise.all([
    setInterpreterTemplate(channel),
    setHaskellFormatterTemplate(channel),
    setHaskellLinterTemplate(channel),
    setCabalFormatterTemplate(channel),
  ]);
  vscode.workspace.onDidChangeConfiguration(async (e) => {
    const promises = [];

    const affectsHaskellInterpreter = e.affectsConfiguration(
      `${my.name}.${LanguageId.Haskell}.interpreter`
    );
    if (affectsHaskellInterpreter) {
      promises.push(setInterpreterTemplate(channel));
    }

    const affectsHaskellFormatter = e.affectsConfiguration(
      `${my.name}.${LanguageId.Haskell}.formatter`
    );
    if (affectsHaskellFormatter) {
      promises.push(setHaskellFormatterTemplate(channel));
    }

    const affectsHaskellLinter = e.affectsConfiguration(
      `${my.name}.${LanguageId.Haskell}.linter`
    );
    if (affectsHaskellLinter) {
      promises.push(setHaskellLinterTemplate(channel));
    }

    const affectsCabalFormatter = e.affectsConfiguration(
      `${my.name}.${LanguageId.Cabal}.formatter`
    );
    if (affectsCabalFormatter) {
      promises.push(setCabalFormatterTemplate(channel));
    }

    await Promise.all(promises);
  });

  if (document) {
    // If the user had a document open when the extension was activated, then
    // it can be used for starting the interpreter.
    startInterpreter(channel, status, collections.ghc, document);
  } else {
    // Otherwise the interpreter command can be run, which will determine the
    // current active document (if there is one).
    commandHaskellInterpret(channel, status, collections.ghc);
  }

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
  if (!document || document.languageId !== LanguageId.Haskell) {
    return;
  }

  collection.delete(document.uri);

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
  languageId: LanguageId,
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
  template: Template,
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

const getRootUri = (uri: vscode.Uri): vscode.Uri =>
  vscode.workspace.getWorkspaceFolder(uri)?.uri ?? Utils.dirname(uri);

async function formatDocumentRange(
  languageId: LanguageId,
  channel: vscode.OutputChannel,
  document: vscode.TextDocument,
  range: vscode.Range,
  token: vscode.CancellationToken
): Promise<vscode.TextEdit[]> {
  const key = newKey();
  const start = perfHooks.performance.now();
  const file = vscode.workspace.asRelativePath(document.uri);
  log(channel, key, `Formatting ${file} using language ${languageId} ...`);

  const rootUri = getRootUri(document.uri);

  let template: Template | undefined = undefined;
  if (languageId === LanguageId.Haskell) {
    template = HASKELL_FORMATTER_TEMPLATE;
  } else if (languageId === LanguageId.Cabal) {
    template = CABAL_FORMATTER_TEMPLATE;
  }
  if (!template) {
    log(channel, key, "Error: Missing formatter command!");
    return [];
  }

  const command = expandTemplate(template, { file });
  const cwd = rootUri.fsPath;
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
  diagnostic.source = "hlint";
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

  const rootUri = getRootUri(document.uri);

  if (!HASKELL_LINTER_TEMPLATE) {
    log(channel, key, "Error: Missing linter command!");
    return [];
  }

  const command = expandTemplate(HASKELL_LINTER_TEMPLATE, { file });
  const cwd = rootUri.fsPath;
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

function messageClassToDiagnosticSeverity(
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

type DiagnosticCode
  = string
  | { value: string, target: vscode.Uri };

function makeDiagnosticCode(classes: string[]): DiagnosticCode {
  let reason: string | undefined;
  let code: string | undefined;
  for (const klass of classes) {
    reason ||= GHC_WARNING_FLAGS[klass];
    code ||= (klass.match(/^GHC-\d+$/) || [])[0];
  }

  reason ||= code || classes.join(" ") || "unknown";
  if (!code) {
    return reason;
  }

  return {
    value: reason,
    target: vscode.Uri.parse(`https://errors.haskell.org/messages/${code}/`),
  };
}

function makeDiagnosticTags(classes: string[]): vscode.DiagnosticTag[] {
  const tags: vscode.DiagnosticTag[] = [];
  for (const klass of classes) {
    if (UNNECESSARY_WARNINGS.has(klass)) {
      tags.push(vscode.DiagnosticTag.Unnecessary);
    }
    if (DEPRECATED_WARNINGS.has(klass)) {
      tags.push(vscode.DiagnosticTag.Deprecated);
    }
  }
  return tags;
}

function messageToDiagnostic(message: Message): vscode.Diagnostic {
  const range = messageSpanToRange(message.span || DEFAULT_MESSAGE_SPAN);

  let severity = vscode.DiagnosticSeverity.Information;
  if (message.severity) {
    severity = messageSeverityToDiagnostic(message.severity);
  } else if (message.messageClass) {
    severity = messageClassToDiagnosticSeverity(message.messageClass);
  }

  const classes = (message.reason || message.messageClass || "").split(/ +/);

  const diagnostic = new vscode.Diagnostic(range, message.doc, severity);
  diagnostic.code = makeDiagnosticCode(classes);
  diagnostic.source = "ghc";
  diagnostic.tags = makeDiagnosticTags(classes);
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

  const document = vscode.window.activeTextEditor?.document;
  if (!INTERPRETER && document) {
    await startInterpreter(channel, status, collection, document);
  }
  if (!INTERPRETER) {
    log(channel, key, "Error: Missing interpreter!");
    return;
  }

  if (INTERPRETER.key) {
    log(channel, key, `Ignoring because ${INTERPRETER.key} is running.`);
    return;
  }

  INTERPRETER.key = key;

  updateStatus(status, true, vscode.LanguageStatusSeverity.Information, "Loading");

  if (document) {
    const rootUri = getRootUri(document.uri);
    collection.delete(rootUri);
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

// If the given string is an absolute path, then it is returned as a file URI.
// Otherwise the relative segment is joined with the root URI.
//
// This is necessary because Cabal uses relative paths and Stack uses absolute
// ones. See the following issues for more details:
//
// - <https://github.com/tfausak/purple-yolk/issues/43>
// - <https://github.com/tfausak/purple-yolk/issues/76>
function toAbsoluteUri(root: vscode.Uri, segment: string): vscode.Uri {
  if (path.isAbsolute(segment)) {
    return vscode.Uri.file(segment)
  }
  return vscode.Uri.joinPath(root, segment);
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

  const rootUri = getRootUri(document.uri);

  if (!INTERPRETER_TEMPLATE) {
    log(channel, key, "Error: Missing interpreter command!");
    return;
  }

  const file = vscode.workspace.asRelativePath(document.uri);
  const command = expandTemplate(INTERPRETER_TEMPLATE, { file });

  if (INTERPRETER) {
    log(channel, key, `Stopping interpreter ${INTERPRETER.task.pid} ...`);
    INTERPRETER.task.kill();
    INTERPRETER = null;
    collection.clear();
  }

  updateStatus(status, true, vscode.LanguageStatusSeverity.Information, "Starting");

  const cwd = rootUri.fsPath;
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
      updateStatus(status, false, vscode.LanguageStatusSeverity.Error, "Exited");
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
        updateStatus(status, false, vscode.LanguageStatusSeverity.Information, "Idle");
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
          assert.ok(match[4]);
          const uri = toAbsoluteUri(rootUri, match[4]);
          collection.delete(uri);
        } else {
          let uri: vscode.Uri | null = null;
          if (message.span) {
            if (message.span.file !== DEFAULT_MESSAGE_SPAN.file) {
              uri = toAbsoluteUri(rootUri, message.span.file);
            }
          } else {
            uri = rootUri;
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
