-- Chomsky.hs
-- Lukas Wagner <xwagne10>
-- BKG-2-CNF 2022
module Chomsky (makeCNF) where

import Types
import Data.List (nub)


-- | Combines pure functions to form single Grammar in CHNF
--
-- Expects grammar already without simple rules on input
makeCNF :: Grammar -> Grammar
makeCNF (Grammar nonterms terms start rules) =
    let (rls, nntrms) = makeRulesCNF (rules, nonterms)
    in
    Grammar (nub $ nonterms ++ nntrms) terms start (nub rls)




-- | Start transforming rules to Chomsky's normal form
--
-- Decides what to do with rule based on length of rule right side
-- and on nuber of nonterms.
makeRulesCNF :: ([GRule],[Nonterm]) -> ([GRule], [Nonterm])
makeRulesCNF (rule@(Rule fromnonterm symbols):rulexs, nonterms)
    | nsymb == 1 && nnont == 0 = -- end rule (N->t)
        let (rls, nntms) = makeRulesCNF (rulexs, nonterms)
        in
            (rule:rls, nntms)
    | nsymb == 2 && nnont == 2 = -- already CHNF rule (N->NN)
        let (rls, nntms) = makeRulesCNF (rulexs, nonterms)
        in
            (rule:rls, nntms)
    | nsymb > 2 = -- rules to be split to multiple CHNF rules (N->SSSS)=(N->NN)(N->NN)(N->NN) (also replace terms)
        let (rls, nntms) = makeRulesCNF (rulexs, nonterms)
            (rls2, nntms2) = divideRuleCNF rule
        in
            (rls2 ++ rls, nntms2 ++ nntms)
    | otherwise = -- rule with right size of 2 but with terms that need to be replaced with nonterms
        let (rls, nntms) = makeRulesCNF (rulexs, nonterms)
            (newsymbs, rls2, nntms2) = makeTermsAliases symbols
        in
            (Rule fromnonterm newsymbs :rls2 ++ rls, nntms2 ++ nntms)
    where
        nsymb = length symbols
        nnont = length (extractNonterms symbols)
makeRulesCNF _ = ([],[]) --failsafe


-- | Used on rules longer than 2, divides them to multiple rules of length 2
-- and makes nonterm aliases for terms and groups
divideRuleCNF :: GRule -> ([GRule], [Nonterm])
divideRuleCNF (Rule fromnonterm symbols@(symbol:symbolxs))
    | length symbols > 2 = -- too long first is taken and rest is made into single nonterm that generates the rest (new rule)
        let (rls, nntrms) = divideRuleCNF (Rule symbolalias symbolxs) -- divides the new rule further
            symbolalias = makeSymbolsAlias symbolxs
        in
            case symbol of -- the first might be term and would need to be replaced
                Ter (Term x) ->  (Rule (Nonterm (x++"'")) [symbol] :(Rule fromnonterm [Non (Nonterm (x++"'")), Non symbolalias] :rls) , symbolalias:nntrms)
                Non (Nonterm _) ->  (Rule fromnonterm [symbol, Non symbolalias] :rls , symbolalias:nntrms)
    | length symbols == 2 = -- correct length, but might have terms to replace
        let (newsyms, rls2, nntrms2) = makeTermsAliases symbols
        in
            (Rule fromnonterm newsyms :rls2, nntrms2)
divideRuleCNF _ = ([],[]) --failsafe

-- | Makes group of symbols into a single nonterm (makes alias for group)
makeSymbolsAlias :: [GSymbol] -> Nonterm
makeSymbolsAlias symbols = Nonterm ("<"++ foldr (\x y -> extractCharSymbol x ++ y) "" symbols ++">")
    where extractCharSymbol a = case a of
            Ter (Term x) ->  x
            Non (Nonterm x) -> x

-- | Finds and replaces terms with nonterms (their alias). Adds new simple rules for aliases
makeTermsAliases :: [GSymbol] -> ([GSymbol],[GRule],[Nonterm])
makeTermsAliases (symbol:symbolxs) =
    let (syms2, rls2, nntrms2) = makeTermsAliases symbolxs in
    case symbol of
        Ter (Term x) -> (Non (Nonterm (x++"'")):syms2, Rule (Nonterm (x++"'")) [Ter (Term x)] :rls2, Nonterm (x++"'"):nntrms2)
        Non no -> (Non no:syms2, rls2, nntrms2)
makeTermsAliases [] = ([],[],[])
