# Информация об инвестиционном инструменте в Тинькофф API
class TinkoffMarketInstrument
    getter figi : String
    getter isin : String
    getter lot : Int32
    getter currency : String
    getter name : String
    getter type : String

    def initialize(@figi, @isin, @lot, @currency, @name, @type)        
    end

    def to_s(io : IO)
        io.puts ("figi: #{figi} isin: #{isin} lot: #{lot} currency: #{currency} name: #{name} type: #{type}")
    end
end