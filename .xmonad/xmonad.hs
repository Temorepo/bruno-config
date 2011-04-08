import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.SetWMName
import XMonad.Actions.CycleWS

import DBus
import DBus.Connection
import DBus.Message
import Control.Monad
import Control.OldException

-- This retry is really awkward, but sometimes DBus won't let us get our
-- name unless we retry a couple times.
getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn` (\ (DBus.Error _ _) ->
                                                getWellKnownName dbus)
 where
  tryGetName = do
    namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
    addArgs namereq [String "org.xmonad.Log", Word32 5]
    sendWithReplyAndBlock dbus namereq 0
    return ()

main = withConnection Session $ \ dbus -> do
  putStrLn "Getting well-known name."
  getWellKnownName dbus
  putStrLn "Got name, starting XMonad."
  xmonad $ gnomeConfig {
      logHook    = dynamicLogWithPP $ defaultPP {
                   ppOutput   = \ str -> do
                     let str'  = "<span font=\"Terminus 9 Bold\">" ++ str ++ 
                                 "</span>"
                         str'' = sanitize str'
                     msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" 
                                "Update"
                     addArgs msg [String str'']
                     -- If the send fails, ignore it.
                     send dbus msg 0 `catchDyn`
                       (\ (DBus.Error _name _msg) ->
                         return 0)
                     return ()
                 , ppTitle    = pangoColor "#FFFFFF"
                 , ppCurrent  = pangoColor "#009999" . wrap "[" "]"
                 , ppVisible  = pangoColor "#996699" . wrap "(" ")"
                 , ppHidden   = wrap " " " "
                 , ppUrgent   = pangoColor "red"
                 , ppLayout   = pangoColor "#999999"
                 },
        startupHook = setWMName "LG3D" -- Makes Java GUIs work
    } `additionalKeysP` (
    [ ("M-d", kill)
    , ("M-t", windows W.focusDown)
    , ("M-n", windows W.focusUp)
    , ("S-M-t", windows W.swapDown)
    , ("S-M-n", windows W.swapUp)
    , ("<F9>", spawn "xsel -o | /home/bruno/bin/pastebin") -- TODO: Show clipboard in dzen
    , ("<Print>", spawn ("/home/bruno/bin/screenshot"))
    , ("M-`", nextScreen)
    , ("S-M-`", shiftNextScreen)
    , ("M-0", shiftTo Next EmptyWS)
    --] ++ [
    --    (otherModMasks ++ "M-" ++ [key], action tag)
    --    |   (tag, key)  <- zip (XMonad.workspaces defaultConfig) "123456789"
    --    , (otherModMasks, action) <- [ ("", windows . W.view)
    --                           , ("S-", windows . W.shift)]
    ])

    --`additionalKeys`
    --    [ ((0, xK_Print), withFocused $ \w -> spawn ("/home/bruno/bin/screenshot " ++ show w))
        --, ((modMask .|. xK_Print), spawn ("/home/bruno/bin/screenshot root"))
    --    ]

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
 where
  left  = "<span foreground=\"" ++ fg ++ "\">"
  right = "</span>"


sanitize :: String -> String
sanitize [] = []
sanitize (x:rest) | fromEnum x > 127 = "&#" ++ show (fromEnum x) ++ "; " ++
                                       sanitize rest
                  | otherwise        = x : sanitize rest
