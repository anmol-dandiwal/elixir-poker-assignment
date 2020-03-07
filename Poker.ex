defmodule Poker do
    def deal(list) do
        hands = dealHands(list, [], [], 1)
        hand1 = elem(hands, 0)
        hand2 = elem(hands, 1)
        pickWinner(hand1, hand2)
    end

    def pickWinner(hand1, hand2) do 
        h1Score = getScore(hand1)
        h2Score = getScore(hand2)
        h1Max = getMaxRank(Enum.sort(getRanks(hand1, [])))
        h2Max = getMaxRank(Enum.sort(getRanks(hand2, [])))
        cond do 
            h1Score > h2Score -> 
                hand1
            h1Score < h2Score ->
                hand2
            h1Score == 10 or h1Score == 9 ->
                tieBreakFlush(hand1, hand2)
            h1Score == 7 or h1Score == 4 -> 
                tieBreakByThrees(hand1, hand2)
            h1Score == 3 -> 
                tieBreakByPair(hand1, hand2)
            true -> 
                tieBreakByRank(hand1, hand2)
        end
    end

    def getScore(hand) do 
        suits = getSuits(hand, [])
        ranks = Enum.sort(getRanks(hand, []))
        score = 
        cond do 
            isRoyalFlush(ranks, suits) -> 
                score = 10
            isStraightFlush(ranks, suits) -> 
                score = 9
            isFourOfAKind(ranks) -> 
                score = 8
            isFullHouse(ranks) -> 
                score = 7
            isFlush(suits) -> 
                score = 6
            isStraight(ranks) -> 
                score = 5
            isThreeOfAKind(ranks) -> 
                score = 4
            isTwoPair(ranks) -> 
                score = 3
            isPair(ranks) -> 
                score = 2
            true -> 
                score = 1
        end
        score
    end

    def tieBreakFlush(hand1, hand2) do 
        h1Suit = hd getSuits(hand1, [])
        h2Suit = hd getSuits(hand2, [])
        cond do 
            (h1Suit == "C") -> 
                hand2
            (h1Suit == "D" and h2Suit != "C") -> 
                hand2
            (h1Suit == "H" and h2Suit == "S") ->
                hand2
            true -> 
                hand1
        end
    end

    def tieBreakByRank([], []) do end
    def tieBreakByRank(hand1, hand2) do 
        h1Ranks = Enum.sort(getRanks(hand1, []))
        h2Ranks = Enum.sort(getRanks(hand2, []))
        cond do 
            getMaxRank(h1Ranks) == 1 and getMaxRank(h2Ranks) > 1 -> 
                hand1
            getMaxRank(h2Ranks) == 1 -> 
                hand2
            getMaxRank(h1Ranks) > getMaxRank(h2Ranks) -> 
                hand1
            getMaxRank(h1Ranks) < getMaxRank(h2Ranks) -> 
                hand2
            getMaxRank(h1Ranks) == getMaxRank(h2Ranks) -> 
                list = tieBreakByRank((tl hand1), (tl hand2))
                cond do 
                    list == tl hand1 ->
                        [(hd hand1) | list]
                    list == tl hand2 -> 
                        [(hd hand2) | list]
                    true ->
                end
            true -> 
        end
    end

    def tieBreakByThrees(hand1, hand2) do 
        midRank1 = hd (tl (tl getRanks(hand1, [])))
        midRank2 = hd (tl (tl getRanks(hand2, [])))
        if (midRank1 < midRank2) do 
            hand2
        else 
            hand1
        end 
    end

    def tieBreakByPair(hand1, hand2) do 
        highPair1 =
        highPair2 =
        newH1 =
        newH2 =
        newH1 = List.delete(hand1, 0)
        newH1 = List.delete(hand1, 2)
        newH1 = List.delete(hand1, 4)
        newH2 = List.delete(hand2, 0)
        newH2 = List.delete(hand2, 2)
        newH2 = List.delete(hand2, 4)
        highPair1 = getMaxRank(Enum.sort(getRanks(newH1, [])))
        highPair2 = getMaxRank(Enum.sort(getRanks(newH2, [])))
        if (highPair1 > highPair2) do 
            hand1
        else 
            hand2
        end  
    end

    def isRoyalFlush(ranks, suits) do
        firstSuit = hd suits
        if (Enum.all?(suits, fn(n) -> n == firstSuit end)) do 
            ranks == [1, 10, 11, 12, 13]
        else
            false
        end
    end

    def isStraightFlush(ranks, suits) do 
        firstSuit = hd suits
        sum = ((hd ranks) + 4) * 2 + ((hd ranks) + 4) / 2
        if (Enum.all?(suits, fn(n) -> n == firstSuit end)) do 
            Enum.reduce(ranks, fn(n, acc) -> n + acc end) == sum
        else
            false
        end
    end

    def isFourOfAKind(ranks) do 
        midCard = hd (tl ranks)
        (Enum.count(ranks, fn(n) -> n == midCard end)) == 4
    end

    def isFullHouse(ranks) do 
        Enum.count(Enum.uniq(ranks)) == 2
    end

    def isFlush(suits) do 
        firstSuit = hd suits
        (Enum.all?(suits, fn(n) -> n == firstSuit end))
    end

    def isStraight(ranks) do 
        index = 0
        Enum.all?(ranks, fn(n) -> 
            n = Enum.at(ranks, index)
            index = index + 1 end)
    end    
    
    def isThreeOfAKind(ranks) do 
        midCard = hd (tl (tl (ranks)))
        (Enum.count(ranks, fn(n) -> n == midCard end)) == 3
    end

    def isTwoPair(ranks) do 
        Enum.count(Enum.uniq(ranks)) == 3
    end

    def isPair(ranks) do
        Enum.count(Enum.uniq(ranks)) == 4
    end

    def getMaxRank(ranks) do 
        if ((hd ranks) == 1) do 
            hd (ranks)
        else 
            hd (Enum.reverse(ranks))
        end
    end 

    def getRanks([], ranks), do: ranks
    def getRanks(hand, ranks) do
        rank = (hd hand) |> String.slice(0..-2)
        getRanks((tl hand), ranks ++ [String.to_integer(rank)])
    end

    def getSuits([], suits), do: suits
    def getSuits(hand, suits) do
        suit = String.at((hd hand), -1)
        getSuits((tl hand), suits ++ [suit])
    end

    def dealHands([], p1, p2, _), do: {p1, p2}
    def dealHands(list, p1, p2, count) do 
        currElem = (hd (list))
        card = 
        cond do 
            (1 <= currElem and currElem <= 13) -> 
                card = "#{currElem}C"   
            (14 <= currElem and currElem <= 26) -> 
                elem = currElem - 13
                card = "#{elem}D"
            (27 <= currElem and currElem <= 39) -> 
                elem = currElem - 26
                card = "#{elem}H"
            (39 <= currElem and currElem <= 52) -> 
                elem = currElem - 39
                card = "#{elem}S"
        end 
        if(rem(count, 2) == 0) do 
            dealHands(tl(list), p1, p2 ++ [card], count + 1)
        else 
            dealHands(tl(list), p1 ++ [card], p2, count + 1)
        end          
    end
end