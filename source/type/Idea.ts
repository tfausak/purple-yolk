import IdeaSeverity from "./IdeaSeverity";

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

export default Idea;
