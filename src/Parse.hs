-- Parse.hs
-- Lukas Wagner <xwagne10>
-- BKG-2-CNF 2022
module Parse (parseInputAsGrammar) where 

import Types


-- | Takes lines of input and returns parsed grammar
--
-- lines of input are matched for correct number of lines,
-- then symbols on lines are send to parsers of grammar components.
parseInputAsGrammar :: Monad m => m [String] -> m Grammar
parseInputAsGrammar inputLines = do
    lns <- inputLines
    case lns of
        (nntrms:trms:start:rulexs) ->
            let
                nonterms' = split (==',') nntrms
                terms' = split (==',') trms
            in
            return $ Grammar
                (parseNonterms nonterms')
                (parseTerms terms')
                (parseStart nonterms' start)
                (parseRules nonterms' terms' rulexs)
        _ ->
            error "Missing part of grammar in input"


-- | Reimplemented "words" function to use predicate.
--
-- as suggested by user Steve in SO question "How to split a string in Haskell?" from 12th Feb 2011
split :: (Char -> Bool) -> [Char] -> [[Char]]
split predicate str =
    case dropWhile predicate str of
        "" -> []
        str2 -> w : split predicate s''
            where (w, s'') = break predicate str2

-- | Just creates nonterms from list of names
parseNonterms :: [String] -> [Nonterm]
parseNonterms (x:xs) =
    Nonterm x : parseNonterms xs
parseNonterms _ = []

-- | Just creates terms from list of names
parseTerms :: [String] -> [Term]
parseTerms (x:xs) =
    Term x : parseTerms xs
parseTerms _ = []

-- | returns starting nonterm and checks for it's existance
parseStart :: [String] -> String -> Nonterm
parseStart nntrms nonterm
    | nonterm `elem` nntrms = Nonterm nonterm
    | otherwise = error "Unknown starting nonterm"

-- | maps lines of input to rules on output
--
-- Line is first parsed until "->" (which is skipped) as nonterm and checked for existance,
-- then line is parsed until end as grammar symbols per character
parseRules :: [String] -> [String] -> [String] -> [GRule]
parseRules nntrms trms = map parseRule
    where
        parseRule string =
            case parseRuleStart1 ([], string) of
                (nntrm, right)
                    | nntrm `elem` nntrms -> Rule (Nonterm nntrm) (parseRuleEnd nntrms trms right)
                    | otherwise -> error "Unknown rule's left side"


-- | First state of parsing until "->"
parseRuleStart1 :: ([Char], [Char]) -> ([Char], [Char])
parseRuleStart1 (_, []) = error "Empty rule in input"
parseRuleStart1 (nntrm, x:xs) =
    case x of
        '-' -> parseRuleStart2 (nntrm, xs)
        _ -> parseRuleStart1 (x:nntrm, xs)

-- | Second state of parsing until "->"
parseRuleStart2 :: ([Char], [Char]) -> ([Char], [Char])
parseRuleStart2 (_, []) = error "Empty rule in input"
parseRuleStart2 (nntrm, x:xs) =
    case x of
        '>' -> (nntrm, xs)
        '-' -> parseRuleStart2 ('-':nntrm, xs)
        _ -> parseRuleStart1 ('-':x:nntrm, xs)

-- | Parsing of grammar symbols
--
-- Char on input is checked against existing nonterms and terms
-- and is treated as such nonterm/term.
--
-- would very much appreciate if split by something => would allow for string names
parseRuleEnd :: [String] -> [String] -> [Char] -> [GSymbol]
parseRuleEnd _ _ [] = []
parseRuleEnd nntrms trms (x:xs)
    | [x] `elem` nntrms = Non (Nonterm [x]) : parseRuleEnd nntrms trms xs
    | [x] `elem` trms = Ter (Term [x]) : parseRuleEnd nntrms trms xs
    | otherwise = error "Unknown character in rule's right side in input"
