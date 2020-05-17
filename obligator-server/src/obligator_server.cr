require "kemal"

require "./tinkoff_api/tinkoff_rest_api"
require "./moex_csv_api/moex_csv_api"

# https://tinkoffcreditsystems.github.io/invest-openapi/swagger-ui/#/market/get_market_bonds


get "/" do
    "Hello World!"
end
  
Kemal.run



# mbonds = MoexCsvApi.getBonds()
# tbonds = TinkoffRestApi.getBonds()

# res = Array(MoexBondInfo).new
# tbonds.each do |tbond|
#     bond = mbonds.find { |mbond| mbond.isin == tbond.isin }
#     res << bond if bond
# end

# res.sort { |a, b| a.couponPercent <=> b.couponPercent  }.each do |x|
#     puts x.to_s
# end

# b = res.first
# p b

# StreamApi.connect(SANDBOX_TOKEN) do |api|
#     api.on_message do |message|
#         case message
#         when InstrumentInfoStreamEvent
#             print message.to_s
#         when OrderbookStreamEvent
#             print message.to_s
#         else
#         end
#     end

#     api.send({
#         event: "orderbook:subscribe",
#         figi: "BBG00QKPP373",
#         depth: 1
#     }.to_json)

#     api.run
# end


# Регистрируется в песочнице
# response = Crest.post(
#   "#{SANDBOX_URL}/sandbox/register",
#   headers: {"Content-Type" => "application/json", "Authorization" => "Bearer #{SANDBOX_TOKEN}"},  
# )

# payload = JSON.parse(response.body)["payload"]
# brokerAccountId = payload["brokerAccountId"]

# response = Crest.get(
#   "#{COMMON_URL}/sandbox/market/bonds",
#   headers: {"Content-Type" => "application/json", "Authorization" => "Bearer #{SANDBOX_TOKEN}"},  
# )

# payload = JSON.parse(response.body)["payload"]
# instruments = payload["instruments"].as_a
# instruments.each do |x|
#     instrument = MarketInstrument.new(x["figi"].as_s, x["ticker"].as_s, x["lot"].as_i, x["name"].as_s, x["type"].as_s)
# end

# client.send({
#     event: "orderbook:subscribe",
#     figi: "BBG00D5L3Q99",
#     depth: 1
# }.to_json)