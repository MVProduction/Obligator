require "json"
require "http/web_socket"

require "./constants"

# Значение в стакане: цена и объём
class CurrentStockInfo
    getter price : Float64
    getter volume : Float64

    def initialize(@price, @volume)        
    end

    def to_s(io : IO)
        io.puts "price: #{price} volume: #{volume}"
    end

    def self.from_json(s : JSON::Any)
        arr = s.as_a
        price = arr[0].to_s.to_f64
        volume = arr[1].to_s.to_f64
        return CurrentStockInfo.new(price, volume)
    end
end

# Событие в Stream API
abstract class StreamEvent
end

# Событие информации инструмента
class InstrumentInfoStreamEvent < StreamEvent
    NAME = "instrument_info"

    getter figi : String
    getter tradeStatus : String
    getter lot : Float64

    def initialize(@figi, @tradeStatus, @lot)
    end

    def self.from_json(s : JSON::Any) : InstrumentInfoStreamEvent
        payload = s["payload"]
        figi = payload["figi"].as_s
        tradeStatus = payload["trade_status"].as_s
        lot = payload["lot"].to_s.to_f64
        return InstrumentInfoStreamEvent.new(figi, tradeStatus, lot)
    end

    def to_s(io : IO)
        io.puts "figi: #{figi} tradeStatus: #{tradeStatus} lot: #{lot}"
    end
end

# Событие стакана
class OrderbookStreamEvent < StreamEvent
    NAME = "orderbook"

    getter figi : String
    getter bids : Array(CurrentStockInfo)
    getter asks : Array(CurrentStockInfo)

    def self.from_json(s : JSON::Any) : OrderbookStreamEvent
        payload = s["payload"]
        figi = payload["figi"].as_s
        jbids = payload["bids"].as_a
        jasks = payload["asks"].as_a

        bids = jbids.map { |x| CurrentStockInfo.from_json(x) }
        asks = jasks.map { |x| CurrentStockInfo.from_json(x) }

        return OrderbookStreamEvent.new(figi, bids, asks)
    end

    def initialize(@figi, @bids, @asks)        
    end    

    def to_s(io : IO)        
        io.puts ("figi: #{figi}")        
        io.puts ("продажа:")
        asks.each do |x|
            io.puts (x)
        end

        io.puts ("покупка:")
        bids.each do |x|
            io.puts (x)
        end
    end    
end

# Для работы со Stream API Тинькофф
class TinkoffStreamApi
    @client : HTTP::WebSocket

    def initialize(@client)        
    end

    def self.connect(token : String, &onconnect : StreamApi -> Void) : StreamApi
        client = HTTP::WebSocket.new(
            URI.parse(STREAM_API_URL),
            HTTP::Headers{"Authorization" => "Bearer #{token}"})

        apiClient = StreamApi.new(client)                               
        onconnect.call(apiClient)

        return apiClient
    end

    def run
        @client.run 
    end

    def on_message(&onmessage : StreamEvent -> Void)
        @client.on_message do |x|
            data = JSON.parse(x)
            eventType = data["event"]
            case eventType
            when InstrumentInfoStreamEvent::NAME
                event = InstrumentInfoStreamEvent.from_json(data)
                onmessage.call(event)
            when OrderbookStreamEvent::NAME
                event = OrderbookStreamEvent.from_json(data)
                onmessage.call(event)
            else
            end            
        end    
    end

    def send(data : String)
        @client.send(data)
    end
end