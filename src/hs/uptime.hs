{-# LANGUAGE ForeignFunctionInterface #-}

import Foreign
import Foreign.C
import Foreign.C.Types (CTime(..))
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime, NominalDiffTime)
import Control.Monad (void)

-- Define timeval struct corresponding to C `struct timeval`
data Timeval = Timeval { sec :: CLong, usec :: CLong }

instance Storable Timeval where
    sizeOf _ = sizeOf (undefined :: CLong) * 2
    alignment _ = alignment (undefined :: CLong)
    peek ptr = do
        sec <- peekElemOff (castPtr ptr) 0
        usec <- peekElemOff (castPtr ptr) 1
        return $ Timeval sec usec
    poke ptr (Timeval sec usec) = do
        pokeElemOff (castPtr ptr) 0 sec
        pokeElemOff (castPtr ptr) 1 usec

foreign import ccall unsafe "sysctlbyname"
    c_sysctlbyname :: CString -> Ptr () -> Ptr CSize -> Ptr () -> CSize -> IO CInt

-- Function to query sysctl values for struct timeval
sysctlTimeval :: String -> IO (Maybe Timeval)
sysctlTimeval name = withCString name $ \cName -> do
    alloca $ \sizePtr -> do
        poke sizePtr (fromIntegral $ sizeOf (undefined :: Timeval))
        alloca $ \valuePtr -> do
            res <- c_sysctlbyname cName (castPtr valuePtr) sizePtr nullPtr 0
            if res == 0
            then Just <$> peek valuePtr
            else return Nothing

-- Calculate uptime based on boot time
getUptime :: IO (Maybe NominalDiffTime)
getUptime = do
    maybeBootTime <- sysctlTimeval "kern.boottime"
    case maybeBootTime of
        Just (Timeval sec _) -> do
            currentTime <- getCurrentTime
            bootTime <- pure $ posixSecondsToUTCTime $ realToFrac sec
            return $ Just $ diffUTCTime currentTime bootTime
        Nothing -> return Nothing

main :: IO ()
main = do
    maybeUptime <- getUptime
    case maybeUptime of
        Just uptime -> putStrLn $ show (floor uptime :: Int)
        Nothing -> putStrLn "Failed to get uptime."
