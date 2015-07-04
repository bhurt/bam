
-- lhs2TeX has the annoying requirement that it wants to be the
-- top of the document- and requires you to include lhs2TeX.fmt
-- and lhs2Tex.sty at the beginning.  But this means you can't
-- partially recompile large tex documents.  And it's easier
-- to simply replace than it is to fix.

import Data.List

main :: IO ()
main = do
    ins <- getContents
    _ <- sequence $ map putStrLn $ latex $ lines ins
    return ()
    where
        latex [] = []
        latex (x:xs) =
            if (x == ">") || ("> " `isPrefixOf` x) then
                startVerb : (unquote (x:xs))
            else if (isStartBlock x) then
                startVerb : (block xs)
            else
                x : (latex xs)
        unquote [] = [ endVerb ]
        unquote (x:xs) =
            if (x == ">") then
                "" : (unquote xs)
            else if ("> " `isPrefixOf` x) then
                (drop 2 x) : (unquote xs)
            else
                endVerb : (latex (x : xs))
        block [] = [ endVerb ]
        block (x:xs) =
            if (isEndBlock x) then
                endVerb : (latex xs)
            else
                x : (block xs)
        isStartBlock x = literalLine "\\begin{code}" x
        isEndBlock x = literalLine "\\end{code}" x
        literalLine lit line =
            let line2 = dropWhile isWhiteSpace line in
            if (lit `isPrefixOf` line2) then
                let line3 = drop (length lit) line2 in
                let line4 = dropWhile isWhiteSpace line3 in
                line4 == ""
            else
                False
        isWhiteSpace ' ' = True
        isWhiteSpace '\t' = True
        isWhiteSpace '\r' = True
        isWhiteSpace '\n' = True
        isWhiteSpace _ = False
        startVerb = "\\begin{verbatim}"
        endVerb = "\\end{verbatim}"

