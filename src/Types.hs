-- Types.hs
-- Lukas Wagner <xwagne10>
-- BKG-2-CNF 2022
module Types where

-- | Terminal specified by its name (String).
newtype Term = Term String deriving(Eq,Show)

-- | Nonterminal specified by its name (String).
newtype Nonterm = Nonterm String deriving(Eq,Show)

-- | Grammar symbol (Terminal/Nonterminal).
data GSymbol = Ter Term  | Non Nonterm deriving(Eq,Show)



-- | Grammar rule.
--
-- Starting nonterm (Left side), List of Symbols (Right side)
data GRule = Rule Nonterm [GSymbol] deriving(Eq,Show)

-- | Grammar.
--
-- Nonterms, Terms, Starting nonterm, Rules
data Grammar = Grammar [Nonterm] [Term] Nonterm [GRule] deriving(Show)




-- | Transforms list of Symbols (of terms and nonterms) to list of only nonterms
--
-- might be useful not only for directly derivable nonterms
extractNonterms :: [GSymbol] -> [Nonterm]
extractNonterms [] = []
extractNonterms (x:xs) =
    case x of
        Non y -> y : extractNonterms xs
        Ter _ -> extractNonterms xs



-- | Prints grammar in assignment specified syntax
printGrammar :: Grammar -> IO ()
printGrammar (Grammar nonterms terms (Nonterm strt) rules) = do
    printNonterms nonterms
    printTerms terms
    putStrLn strt
    printRules rules

-- | Prints nonterminals on a line separated by comma
printNonterms :: [Nonterm] -> IO ()
printNonterms [] = putStr "\n"
printNonterms ((Nonterm x):y:xs) = do
    putStr (x ++ ",")
    printNonterms (y:xs)
printNonterms ((Nonterm x):xs) = do
    putStr x
    printNonterms xs

-- | Prints terminals on a line separated by comma
printTerms :: [Term] -> IO ()
printTerms [] = putStr "\n"
printTerms ((Term x):y:xs) = do
    putStr (x ++ ",")
    printTerms (y:xs)
printTerms ((Term x):xs) = do
    putStr x
    printTerms xs

-- | Prints rule on a line as "N->SSS"
printRules :: [GRule] -> IO ()
printRules [] = return ()
printRules ((Rule (Nonterm nntrm) syms):xs) = do
    putStr nntrm
    putStr "->"
    printSymbols syms
    putStr "\n"
    printRules xs

-- | Prints symbol (nonterminal/terminal) without ending line
printSymbols :: [GSymbol] -> IO ()
printSymbols [] = return ()
printSymbols (x:xs) = do
    case x of
        Ter (Term t) -> putStr t
        Non (Nonterm n) -> putStr n
    printSymbols xs