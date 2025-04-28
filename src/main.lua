local debugMode = false
local logToFile
local debugPrint

local function takeCard(hand)
    table.insert(hand, table.remove(deck, love.math.random(#deck))) -- # operator returns the number of elements in the table
end

function love.load()
    logToFile("love.load start")    
    -- init deck
    deck = {}
    for suitIndex, suitValue in ipairs({"hearts", "diamonds", "clubs", "spades"}) do
        for rankIndex, rankValue in ipairs({"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}) do
            table.insert(deck, {suit = suitValue, rank = rankValue})
            debugPrint('suit: '..suitValue..', rank: '..rankValue)
        end
    end

    -- deal starting hands
    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)
    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)

    logToFile("love.load complete")
end

function love.update(dt)
end

function love.draw()
    local output = {}
    table.insert(output, "--- Player Hand ---")
    for cardIndex, card in ipairs(playerHand) do
        table.insert(output, "suit: "..card.suit..", rank: "..card.rank)
    end
    table.insert(output, "")
    table.insert(output, "--- Dealer Hand ---")
    for cardIndex, card in ipairs(dealerHand) do
        table.insert(output, "suit: "..card.suit..", rank: "..card.rank)
    end
    love.graphics.print(table.concat(output, "\n"), 15, 15)
end

function love.keypressed(key)
    if key == "h" then
        takeCard(playerHand)
        logToFile("Player took a card")
    elseif key == "escape" then
        logToFile("Quitting game")
        love.event.quit()
    end
end

logToFile = function(message)
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]") 
    local file = io.open("blackjack-log.txt", "a")   
    file:write(timestamp .. " " .. message .. "\n")   
    file:close()                                   
end

debugPrint = function(message)
    if debugMode then
        print(message)
    end
end