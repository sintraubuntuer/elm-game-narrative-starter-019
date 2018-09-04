module ListZipper exposing (Zipper, zipperCurrent, zipperFromList, zipperNext, zipperSingleton, zipperWithDefault)

-- This was copied from https://github.com/wernerdegroot/listzipper
-- while the List.Zipper package doesn't get updated to Elm 0.19 version


type Zipper a
    = Zipper (List a) a (List a)


{-| Returns the element the `Zipper` is currently focussed on.
-}
zipperCurrent : Zipper a -> a
zipperCurrent (Zipper _ x _) =
    x


{-| Move the focus to the element after the element the `Zipper` is currently focussed on (if there is such an element).
-}
zipperNext : Zipper a -> Maybe (Zipper a)
zipperNext (Zipper ls x rs) =
    case rs of
        [] ->
            Nothing

        y :: ys ->
            Just <| Zipper (x :: ls) y ys


{-| Construct a `Zipper` focussed on the first element of a singleton list.
-}
zipperSingleton : a -> Zipper a
zipperSingleton x =
    Zipper [] x []


{-| Construct a `Zipper` from a list. The `Zipper` will focus on the first element (if there is a first element).
-}
zipperFromList : List a -> Maybe (Zipper a)
zipperFromList xs =
    case xs of
        [] ->
            Nothing

        y :: ys ->
            Just (Zipper [] y ys)


{-| Provide an alternative when constructing a `Zipper` fails.
-}
zipperWithDefault : a -> Maybe (Zipper a) -> Zipper a
zipperWithDefault x =
    Maybe.withDefault (zipperSingleton x)
