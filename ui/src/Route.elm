module Route exposing (Route(..), fromUrl, href, modifyUrl, newUrl)

import Browser.Navigation as Navigation exposing (Key)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string, top)


type Route
    = Unknown String
    | Home
    | Mailbox String
    | Message String String
    | Monitor
    | Status


{-| Routes our application handles.
-}
routes : List (Parser (Route -> a) a)
routes =
    [ map Home top
    , map Message (s "m" </> string </> string)
    , map Mailbox (s "m" </> string)
    , map Monitor (s "monitor")
    , map Status (s "status")
    ]


{-| Convert route to a URI.
-}
routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Unknown _ ->
                    []

                Home ->
                    []

                Mailbox name ->
                    [ "m", name ]

                Message mailbox id ->
                    [ "m", mailbox, id ]

                Monitor ->
                    [ "monitor" ]

                Status ->
                    [ "status" ]
    in
    "/" ++ String.join "/" pieces



-- PUBLIC HELPERS


href : Key -> Route -> Attribute msg
href key route =
    Attr.href (routeToString route)


modifyUrl : Key -> Route -> Cmd msg
modifyUrl key =
    routeToString >> Navigation.replaceUrl key


newUrl : Key -> Route -> Cmd msg
newUrl key =
    routeToString >> Navigation.pushUrl key


{-| Returns the Route for a given URL.
-}
fromUrl : Url -> Route
fromUrl location =
    case Parser.parse (oneOf routes) location of
        Nothing ->
            Unknown location.path

        Just route ->
            route