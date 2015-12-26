-- very trivial client and server program (in one file) using the Network high level interface


import Control.Concurrent
import Network
import System.IO


main :: IO()
main  = do
  mvar_end_program_server <- newEmptyMVar
  mvar_end_program_client <- newEmptyMVar
  _ <- forkIO $ do  --server
    sock <- listenOn (PortNumber 7777)
    (handler , host , port)<- accept sock -- in this case the alias res as well as host and port are ignored
    hSetBuffering handler LineBuffering
    msg <- hGetLine handler
    putStrLn ("recieved form " ++ show host ++ " on port " ++ show port ++ " the following message: " ++ msg)
    msg2 <- hGetLine handler
    putStrLn ("recieved form " ++ show host ++ " on port " ++ show port ++ " the following message: " ++ msg2)
    sClose sock
    putMVar mvar_end_program_server ()

  _ <- forkIO $ do --client
    handle <- connectTo "127.0.0.1" (PortNumber 7777)
    hSetBuffering handle LineBuffering
    sending handle
    sending handle
    hClose handle
    putMVar mvar_end_program_client ()
  takeMVar mvar_end_program_client --let the main program wain for the child processes
  takeMVar mvar_end_program_server
  putStrLn "exiting program now"


sending :: Handle -> IO()
sending handle = do
  str <- getLine
  hPutStr handle (str ++ "\n")
