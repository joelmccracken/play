import IO


main = do fromHandle <- getAndOpenFile "Copy from: " ReadMode
          toHandle   <- getAndOpenFile "Copy to: " WriteMode 
          contents   <- hGetContents fromHandle
          hPutStr toHandle contents
          hClose toHandle
          putStr "Done."

getAndOpenFile          :: String -> IOMode -> IO Handle

getAndOpenFile prompt mode =
    do putStr prompt
       hFlush stdout
       name <- getLine
       catch (openFile name mode)
             (\_ -> do putStrLn ("Cannot open "++ name ++ "\n")
	               getAndOpenFile prompt mode)
 
