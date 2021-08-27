{-# LANGUAGE OverloadedStrings, ScopedTypeVariables, CPP #-}
{- |
Module      : Text.Pandoc.Image
Copyright   : Copyright (C) 2020-2021 John MacFarlane
License     : GNU GPL, version 2 or above

Maintainer  : John MacFarlane <jgm@berkeley.edu>
Stability   : alpha
Portability : portable

Functions for converting images.
-}
module Text.Pandoc.Image ( svgToPng ) where
import Text.Pandoc.Options (WriterOptions(..))
import Text.Pandoc.Process (pipeProcess)
import qualified Data.ByteString.Lazy as L
import System.Exit
import Data.Text (Text)
import Text.Pandoc.Shared (tshow)
import qualified Control.Exception as E

-- | Convert svg image to png. rsvg-convert
-- is used and must be available on the path.
svgToPng :: Int           -- ^ DPI
         -> L.ByteString  -- ^ Input image as bytestring
         -> IO (Either Text L.ByteString)
svgToPng dpi bs = do
  let dpi' = show dpi
  E.catch
       (do (exit, out) <- pipeProcess Nothing "rsvg-convert"
                          ["-f","png","-a","--dpi-x",dpi',"--dpi-y",dpi']
                          bs
           return $ if exit == ExitSuccess
              then Right out
              else Left "conversion from SVG failed")
       (\(e :: E.SomeException) -> return $ Left $
           "check that rsvg-convert is in path.\n" <> tshow e)
