-- Nonsimple.hs
-- Lukas Wagner <xwagne10>
-- BKG-2-CNF 2022
module Nonsimple (removeSimple) where

import Types
import Data.List (nub)


-- | Combines pure functions to form single Grammar
removeSimple :: Grammar -> Grammar
removeSimple (Grammar nonterms terms start rules) =
    Grammar nonterms terms start (createNonsimpleRules (generateAllDerivable rules nonterms) rules)




-- | Generates all nonterms derivable from every nonterm in finite number of steps.
--
-- this defines fixpoint looping for every starting nonterm
generateAllDerivable :: [GRule] -> [Nonterm] ->  [(Nonterm,[Nonterm])]
generateAllDerivable rules = map (\ x -> ( x, derived rules [x]))
    where
        derived _ [] = error "How? Can't derive not even itself?"
        derived rules' set
            | next /= set = derived rules' next
            | otherwise = set
                where next = nub $ nextDerivingStepDIRECT rules' set ++ set

-- | Generates set of nonterms derivable from set of nonterms (starting nonterm in first iteration)
-- after single application of rules
--
-- Basicaly for over set of already found nonterms
nextDerivingStepDIRECT :: [GRule] -> [Nonterm] -> [Nonterm]
nextDerivingStepDIRECT _ [] = []
nextDerivingStepDIRECT rules (x:xs) =
    generateSingleDerivedDIRECT rules x ++ nextDerivingStepDIRECT rules xs

-- | Generates set of nonterms derivable from single nonterm in single iteration of rules
--
-- basicaly for over rules
generateSingleDerivedDIRECT :: [GRule] -> Nonterm -> [Nonterm]
generateSingleDerivedDIRECT rulexs x
  = foldr (\ rule -> (++) (expandRuleDIRECT rule x)) [] rulexs

-- | Generates set of (1 or 0) nonterms derivable from single nonterm and single rule
expandRuleDIRECT :: GRule -> Nonterm -> [Nonterm]
expandRuleDIRECT (Rule fromnonterm symbols) x
    | x == fromnonterm && length symbols == 1 = extractNonterms symbols
    | otherwise = []



-- | Start of elimination of simple rules
--
-- for over every rule
createNonsimpleRules :: [(Nonterm,[Nonterm])] -> [GRule] -> [GRule]
createNonsimpleRules sets (rule:rulexs) =
    expandRuleRULES sets rule ++ createNonsimpleRules sets rulexs
createNonsimpleRules _ _ = []

-- | Generates nonsimple rules from simple rules.
--
-- If rule not simple, for every simple
-- creates list of directly derivable rules from this rule
-- gets one rule and all nonterms derivable from all nonterms
-- if base nonterm of rule is derivable from other nonterm (is in his derivable set)
-- new rule should be created for every such nonterm from which base nonterm of rule is derivable
expandRuleRULES ::  [(Nonterm,[Nonterm])] -> GRule -> [GRule]
expandRuleRULES  (reachable:reachablexs) rule@(Rule _ symbols)
    | length symbols == 1 && length (extractNonterms symbols) == 1 = []
    | otherwise = case expandFromSetRULES reachable rule of
        Just x -> x : expandRuleRULES reachablexs rule
        Nothing -> expandRuleRULES reachablexs rule
expandRuleRULES  _ _ = []

-- | If possible generates new derived rule derivable from Nonterm.
--
-- If base nonterm of rule is derivable from other nonterm (is in his derivable set)
-- create new rule if rule is directly derivable from somewhere.
expandFromSetRULES :: (Nonterm,[Nonterm]) -> GRule -> Maybe GRule
expandFromSetRULES (from ,derivables) (Rule fromnonterm symbols)
    | fromnonterm `elem` derivables = Just (Rule from symbols)
    | otherwise  = Nothing
