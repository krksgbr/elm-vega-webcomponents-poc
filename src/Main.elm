module Main exposing (main)

import BarChart
import Browser
import Browser.Navigation as Nav
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
import Url exposing (Url)


type alias Flags =
    {}


type alias CustomEvent a =
    { detail : a
    }


decodeCustomEvent : (a -> msg) -> JD.Decoder a -> JD.Decoder msg
decodeCustomEvent toMsg decoder =
    JD.map toMsg <|
        JD.map .detail <|
            JD.map CustomEvent
                (JD.field "detail" decoder)


type alias Model =
    { data : List BarChart.Datum
    , newCategory : String
    , newValue : String
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { data =
            [ { category = "A", amount = 28 }
            , { category = "B", amount = 55 }
            ]
      , newCategory = ""
      , newValue = ""
      }
    , Cmd.none
    )


type Msg
    = FormSubmitted
    | LabelUpdated String
    | ValueUpdated String
    | NoOp
    | DatumClicked BarChart.Datum


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LabelUpdated str ->
            ( { model | newCategory = str }, Cmd.none )

        ValueUpdated str ->
            ( { model | newValue = str }, Cmd.none )

        FormSubmitted ->
            let
                newModel =
                    String.toFloat model.newValue
                        |> Maybe.map
                            (\amount ->
                                { model
                                    | newCategory = ""
                                    , newValue = ""
                                    , data =
                                        model.data
                                            ++ [ { category = model.newCategory
                                                 , amount = amount
                                                 }
                                               ]
                                }
                            )
                        |> Maybe.withDefault model
            in
            ( newModel
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )

        DatumClicked datum ->
            ( { model
                | data =
                    model.data
                        |> List.filter
                            (\{ category } ->
                                category /= datum.category
                            )
              }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title = "elm-vega-webcomponents"
    , body =
        [ H.div []
            [ H.node "vega-element"
                [ HA.attribute "spec" <| JE.encode 0 <| BarChart.spec model.data
                , HE.on "datumClicked" <|
                    decodeCustomEvent DatumClicked BarChart.datumDecoder
                ]
                []
            , H.div []
                [ H.div []
                    [ H.label [ HA.for "label" ]
                        [ H.text "label" ]
                    , H.input
                        [ HA.type_ "text"
                        , HA.id "label"
                        , HA.value model.newCategory
                        , HE.onInput LabelUpdated
                        ]
                        []
                    ]
                , H.div []
                    [ H.label [ HA.for "value" ] [ H.text "value" ]
                    , H.input
                        [ HA.id "value"
                        , HA.type_ "text"
                        , HA.value model.newValue
                        , HE.onInput ValueUpdated
                        ]
                        []
                    ]
                , H.button
                    [ HE.onClick FormSubmitted
                    ]
                    [ H.text "Add" ]
                ]
            ]
        ]
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = always NoOp
        , onUrlRequest = always NoOp
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
