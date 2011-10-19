import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Xfce
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W
import qualified Data.Map as M

import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName

import XMonad.Layout.LimitWindows
import XMonad.Layout.Magnifier
import XMonad.Layout.NoBorders
import XMonad.Layout.Named

import DBus
import DBus.Connection
import DBus.Message
import Control.Monad
import Control.OldException

myLayout = named "Tall" layout ||| named "Wide" (Mirror layout) ||| noBorders Full
    where
        tall = Tall 1 (3/100) 0.6
        layout = smartBorders tall

main = withConnection Session $ \ dbus -> do
  getWellKnownName dbus
  xmonad $ xfceConfig {
    logHook = dynamicLogWithPP (prettyPrinter dbus),
    layoutHook = desktopLayoutModifiers $ myLayout,
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
    ])

prettyPrinter :: Connection -> PP
prettyPrinter dbus = defaultPP
    { ppOutput   = dbusOutput dbus
    , ppTitle    = pangoSanitize
    , ppCurrent  = pangoColor "green" . wrap "[" "]" . pangoSanitize
    , ppVisible  = pangoColor "yellow" . wrap "(" ")" . pangoSanitize
    , ppHidden   = const ""
    , ppUrgent   = pangoColor "red"
    , ppLayout   = const ""
    , ppSep      = " "
    }

getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn` (\(DBus.Error _ _) -> getWellKnownName dbus)
  where
    tryGetName = do
        namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
        addArgs namereq [String "org.xmonad.Log", Word32 5]
        sendWithReplyAndBlock dbus namereq 0
        return ()

dbusOutput :: Connection -> String -> IO ()
dbusOutput dbus str = do
    msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" "Update"
    addArgs msg [String ("<b>" ++ str ++ "</b>")]
    -- If the send fails, ignore it.
    send dbus msg 0 `catchDyn` (\(DBus.Error _ _) -> return 0)
    return ()

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
  where
    left  = "<span foreground=\"" ++ fg ++ "\">"
    right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
  where
    sanitize '>'  xs = "&gt;" ++ xs
    sanitize '<'  xs = "&lt;" ++ xs
    sanitize '\"' xs = "&quot;" ++ xs
    sanitize '&'  xs = "&amp;" ++ xs
    sanitize x    xs = x:xs
