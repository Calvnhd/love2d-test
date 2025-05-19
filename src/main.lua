local debugMode = false
local logToFile
local debugPrint

local function takeCard(hand)
    table.insert(hand, table.remove(deck, love.math.random(#deck))) -- # operator returns the number of elements in the table
end

-- initialization function
function love.load()
    logToFile("love.load start")

    -- load image files
    images = {}
    for nameIndex, name in ipairs({
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        'pip_heart', 'pip_diamond', 'pip_club', 'pip_spade',
        'mini_heart', 'mini_diamond', 'mini_club', 'mini_spade',
        'card', 'card_face_down',
        'face_jack', 'face_queen', 'face_king',
    }) do
        images[name] = love.graphics.newImage('images/'..name..'.png')
    end

    -- init deck
    deck = {}
    for suitIndex, suitValue in ipairs({"hearts", "diamonds", "clubs", "spades"}) do
        for rankIndex, rankValue in ipairs({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}) do
            table.insert(deck, {
                suit = suitValue,
                rank = rankValue
            })
            debugPrint('suit: ' .. suitValue .. ', rank: ' .. rankValue)
        end
    end

    -- deal starting hands
    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)
    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)

    -- feels weird putting this here but hey
    roundOver = false

    -- I don't like putting functions in functions but okay
    function getTotal(hand)
        local total = 0
        local bHasAce = false
        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            else
                total = total + card.rank
            end
            if card.rank == 1 then
                bHasAce = true
            end
        end
        if bHasAce and total <= 11 then
            total = total + 10
        end
        return total
    end

    logToFile("love.load complete")
end

-- tick function
function love.update(dt)
end

-- draw function
function love.draw()

    -- building the string (output) to display
    local output = {}

    -- add player info 
    table.insert(output, "--- Player Hand ---")
    for cardIndex, card in ipairs(playerHand) do
        table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
    end
    table.insert(output, "Total: " .. getTotal(playerHand))

    -- new line
    table.insert(output, "")

    -- add Dealer info
    table.insert(output, "--- Dealer Hand ---")
    for cardIndex, card in ipairs(dealerHand) do
        if not roundOver and cardIndex == 1 then
            table.insert(output, '(Card hidden)')
        else
            table.insert(output, "suit: " .. card.suit .. ", rank: " .. card.rank)
        end
    end
    if roundOver then
        table.insert(output, 'Total: '..getTotal(dealerHand))
    else
        table.insert(output, 'Total: ?')
    end

    -- round over info
    if roundOver then
        table.insert(output, '')

        local function hasHandWon(thisHand, otherHand)
            return getTotal(thisHand) <= 21 and (getTotal(otherHand) > 21 or getTotal(thisHand) > getTotal(otherHand))
        end

        if hasHandWon(playerHand, dealerHand) then
            table.insert(output, 'Player wins')
        elseif hasHandWon(dealerHand, playerHand) then
            table.insert(output, 'Dealer wins')
        else
            table.insert(output, 'Draw')
        end
    end

    -- print resulting string to a table
    love.graphics.print(table.concat(output, "\n"), 15, 15)

end

-- input
function love.keypressed(key)
    if not roundOver then
        if key == 'h' then
            takeCard(playerHand)
            if getTotal(playerHand) >= 21 then
                roundOver = true
            end
        elseif key == 's' then
            roundOver = true
        end
        if roundOver then
            while getTotal(dealerHand) < 17 do
                takeCard(dealerHand)
            end
        end
    else
        love.load()
    end
end

-- logs message input into a file
logToFile = function(message)
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
    local file = io.open("blackjack-log.txt", "a")
    file:write(timestamp .. " " .. message .. "\n")
    file:close()
    debugPrint(message)
end

-- prints message to console
debugPrint = function(message)
    if debugMode then
        print(message)
    end
end
