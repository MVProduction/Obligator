require "json"

require "../common/settings_manager"
require "./tinkoff_api_constants"
require "./tinkoff_market_instrument"

# Rest API Тинькоффа
class TinkoffRestApi
    # Возвращает список облигаций
    def self.getBonds() : Array(TinkoffMarketInstrument)
        token = SettingsManager.instance.get("tinkoff_sandbox_token")

        response = Crest.get(
            "#{COMMON_URL}/sandbox/market/bonds",
            headers: {"Content-Type" => "application/json", "Authorization" => "Bearer #{token}"},  
        )

        res = Array(TinkoffMarketInstrument).new

        payload = JSON.parse(response.body)["payload"]        
        instruments = payload["instruments"].as_a
        instruments.each do |x|
            instrument = TinkoffMarketInstrument.new(
                figi: x["figi"].as_s, 
                isin: x["isin"].as_s, 
                lot: x["lot"].as_i, 
                currency: x["currency"].as_s,
                name: x["name"].as_s, 
                type: x["type"].as_s)
            res.push(instrument)
        end

        return res
    end
end