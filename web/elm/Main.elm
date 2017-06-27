port module Main exposing (..)

import Html exposing (Html, div, text, program, button)
import Html.Events exposing (onClick)
import Collage exposing (..)
import Element exposing (..)
import Color exposing (..)
import Task exposing (..)
import Window
import Mouse exposing (..)
import Html.Lazy exposing (lazy)
import Ui.Ratings
import Html.Attributes exposing (..)
import String exposing (toList, fromList, reverse)


-- MODELa


xxxx : String
xxxx =
    toString 124


type alias Position =
    { x : Int, y : Int }


type alias Model =
    { rotate : Float
    , a : Int
    , b : Int
    , primes : List Int
    , text : String
    , size : Window.Size
    , points : List Position
    , ratings : Ui.Ratings.Model
    , inputs : List Msg
    }


init : ( Model, Cmd Msg )
init =
    ( { rotate = 0
      , a = 0
      , b = 1
      , text = ""
      , primes = [ 2 ]
      , size = Window.Size 0 0
      , points = []
      , ratings =
            Ui.Ratings.init ()
                |> Ui.Ratings.size 10
      , inputs = []
      }
    , Task.perform (\x -> Resize x) Window.size
    )



-- PORTS


port check : String -> Cmd msg



-- port for listening for suggestions from JavaScript


port suggestions : (List String -> msg) -> Sub msg



-- MESSAGES


type Msg
    = NoOp
    | Rotate
    | Fibbonaci
    | Primes
    | Resize Window.Size
    | Draw Position
    | Ratings Ui.Ratings.Msg
    | Clear
    | Next
    | Append (List Msg)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [
         canvas model |> Element.toHtml
        ]



--


orElse : x -> Maybe x -> x
orElse def x =
    case x of
        Just sth ->
            sth

        Nothing ->
            def


stringzmiana str =
    let
        helper acc strh =
            case strh of
                a :: b :: c ->
                    helper (a :: b :: acc) c

                a :: [] ->
                    a :: acc

                [] ->
                    acc
    in
        str |> toList |> helper [] |> fromList |> reverse



--


postoXY : Position -> ( Float, Float )
postoXY pos =
    ( pos.x |> toFloat, pos.y |> toFloat )


path : Model -> Path
path model =
    Collage.path (List.map postoXY model.points)


canvas : Model -> Element
canvas model =
    let
        width =
            model.size.width

        height =
            model.size.height
    in
        Collage.collage width
            height
            [ dupa model
            , traced (solid black) (path model)
            ]



--zly kod ktory nie dziala


aaa =
    1


dupa : Model -> Form
dupa model =
    let
        width =
            model.size.width |> toFloat

        height =
            model.size.height |> toFloat
    in
        Collage.rect 100 100 |> Collage.filled Color.red |> Collage.rotate model.rotate



-- UPDATE


{--}
last : List a -> Maybe a
last xs =
    case xs of
        [] ->
            Nothing

        [ h ] ->
            Just h

        h :: t ->
            last t


dropWhile : (a -> Bool) -> List a -> List a
dropWhile fun xs =
    case xs of
        h :: t ->
            if fun (h) == True then
                takeWhile fun t
            else
                xs

        _ ->
            xs


takeWhile : (a -> Bool) -> List a -> List a
takeWhile fun xs =
    case xs of
        h :: t ->
            if fun (h) == True then
                h :: takeWhile fun t
            else
                xs

        _ ->
            xs

primesWithNext : List Int -> Int -> List Int
primesWithNext xs n =
    let
        list =
            xs |> dropWhile (\x -> x * x > n)
    in
        if List.any (\x -> n % x == 0) list then
            primesWithNext xs (n + 1)
        else
            n :: xs



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Rotate ->
            { model | rotate = model.rotate + 0.0001, inputs = model.inputs ++ [ Rotate ] }
                ! [ {--}
                    Task.perform (always Next) (Task.succeed ()) --}
                  ]

        Fibbonaci ->
            { model
                | a = model.b
                , b = model.a + model.b
                , text = model.text ++ "\n" ++ (model.a |> toString)
                , inputs = model.inputs ++ [ Fibbonaci ]
            }
                ! [ Task.perform (always Next) (Task.succeed ()) ]

        Primes ->
            let
                n =
                    case (model.primes |> List.head) of
                        Just x ->
                            x + 1

                        Nothing ->
                            -1
            in
                { model | primes = primesWithNext model.primes n }
                    ! []

        Resize newSize ->
            { model | size = newSize }
                ! []

        Draw point ->
            { model
                | points =
                    { point
                        | x = point.x - floor ((toFloat model.size.width) / 2)
                        , y = floor ((toFloat model.size.height) / 2) - point.y
                    }
                        :: model.points
            }
                ! []

        Ratings data ->
            let
                ( ratings, cmd ) =
                    Ui.Ratings.update data model.ratings
            in
                ( { model | ratings = ratings }, Cmd.map Ratings cmd )

        Clear ->
            { model | inputs = [] }
                ! [ Task.perform (always NoOp) (Task.succeed ()) ]

        Next ->
            let
                tail =
                    case model.inputs |> List.tail of
                        Just t ->
                            t

                        Nothing ->
                            []

                head =
                    case model.inputs |> List.head of
                        Just h ->
                            h

                        Nothing ->
                            NoOp
            in
                { model | inputs = tail }
                    ! [ Task.perform (always head) (Task.succeed ()) ]

        Append msgList ->
            { model | inputs = model.inputs ++ msgList }
                ! [ Task.perform (always Next) (Task.succeed ()) ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes (\s -> Resize s)
        , Mouse.moves Draw
        ]



-- MAIN


main : Program Never Model Msg
main =
     Html.text "Hello from Elm"
     {--program
        { init = init
        , view = lazy view
        , update = update
        , subscriptions = subscriptions
        }
--}