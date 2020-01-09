module BarChart exposing (Datum, datumDecoder, spec)

import Json.Decode as JD
import Vega exposing (..)


type alias Datum =
    { category : String
    , amount : Float
    }


datumDecoder : JD.Decoder Datum
datumDecoder =
    JD.map2 Datum
        (JD.field "category" JD.string)
        (JD.field "amount" JD.float)


spec : List Datum -> Spec
spec data =
    let
        categories =
            data
                |> List.map .category

        values =
            data
                |> List.map .amount

        ds =
            let
                table =
                    dataFromColumns "table" []
                        << dataColumn "category" (vStrs categories)
                        << dataColumn "amount" (vNums values)
            in
            dataSource [ table [] ]

        si =
            signals

        sc =
            scales
                << scale "xScale"
                    [ scType scBand
                    , scDomain (doData [ daDataset "table", daField (field "category") ])
                    , scRange raWidth
                    , scPadding (num 0.05)
                    ]
                << scale "yScale"
                    [ scType scLinear
                    , scDomain (doData [ daDataset "table", daField (field "amount") ])
                    , scRange raHeight
                    ]

        ax =
            axes
                << axis "xScale" siBottom []
                << axis "yScale" siLeft []

        mk =
            marks
                << mark rect
                    [ mFrom [ srData (str "table") ]
                    , mEncode
                        [ enEnter
                            [ maX [ vScale "xScale", vField (field "category") ]
                            , maWidth [ vScale "xScale", vBand (num 1) ]
                            , maY [ vScale "yScale", vField (field "amount") ]
                            , maY2 [ vScale "yScale", vNum 0 ]
                            ]
                        ]
                    ]
    in
    toVega
        [ width 400
        , height 200
        , padding 5
        , ds
        , si []
        , sc []
        , ax []
        , mk []
        ]
