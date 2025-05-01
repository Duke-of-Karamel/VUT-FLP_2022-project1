-- Main.hs
-- Lukas Wagner <xwagne10>
-- BKG-2-CNF 2022

import System.Environment ( getArgs )

import Types ( Grammar, printGrammar )
import Parse ( parseInputAsGrammar )
import Nonsimple ( removeSimple )
import Chomsky ( makeCNF )

import Control.Applicative ((<$>))
-- ^ coz MERLIN IS RETARDED AND USES 10 YEARS, YES, 10 YEARS OLD VERSION OF GHC   


-- | program entry
main :: IO ()
main = do
    args <- getArgs
    decideArgs Nothing args

{- | Remembers last grammar and parses arguments

    For first time (grammar is Nothing) iterates arguments until unknown argument => probably file path.
    If uknown argument is not found takes grammar from stdin.
    With loaded grammar executes arguments in order.
    On uknown argument (if not last) (is currently loaded filepath) find next filepath and loads new grammar,
    then continues to execute in order.
-}
decideArgs :: Maybe Grammar -> [[Char]] -> IO ()
decideArgs _ [] = do return ()
decideArgs grammar (arg:argxs) = do
    case arg of
        "-i" -> do
            grmmr <- getGrammar grammar
            _rewriteOut grmmr
            decideArgs (Just grmmr) argxs
        "-1" -> do
            grmmr <- getGrammar grammar
            _removeSimple grmmr
            decideArgs (Just grmmr) argxs
        "-2" -> do
            grmmr <- getGrammar grammar
            _makeCNF grmmr
            decideArgs (Just grmmr) argxs
        _ -> do
            case argxs of
                [] -> return ()
                _ -> do
                    grammart <-  parseInputAsGrammar $ getInputAsLines $ getFileMaybe argxs
                    decideArgs (Just grammart) argxs
    where getGrammar grammar' = do
            case grammar' of 
                Nothing -> do parseInputAsGrammar $ getInputAsLines $ getFileMaybe argxs
                Just gram -> return gram


-- | Iterates arguments until one that does not start with "-"
--
-- returns first unknown argument => prly filepath
getFileMaybe :: [[Char]] -> Maybe [Char]
getFileMaybe [] = Nothing
getFileMaybe (x:xs) =
    if head x == '-' then
        getFileMaybe xs
    else
        Just x

-- | Takes maybe filepath and returns list of lines read
--
-- With filepath returns file contents.
-- Without filepath returns stdin contents.
getInputAsLines :: Maybe FilePath -> IO [String]
getInputAsLines fileMaybe = do
    case fileMaybe of
        Just filename -> do
            lines <$> readFile filename
        Nothing -> do
            lines <$> getContents



-- | Interface between pure functions and printing
_rewriteOut :: Grammar -> IO ()
_rewriteOut grmmr = do
    printGrammar grmmr

-- | Interface between pure functions and printing
_removeSimple :: Grammar -> IO ()
_removeSimple grmmr = do
    printGrammar $ removeSimple grmmr

-- | Interface between pure functions and printing
_makeCNF :: Grammar -> IO ()
_makeCNF grmmr = do
    printGrammar $ makeCNF $ removeSimple grmmr
