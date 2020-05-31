require "json"
require "option_parser"

require "invest_api"

fieldStr = "name,isin,price"
orderStr = ""

begin
    OptionParser.parse do |parser|
        parser.banner = "Использование: obligator_console [аргументы]"
        parser.on("-f name,isin,price", "--field=name,isin,price", "Задаёт поля облигации") { |x| fieldStr = x }
        parser.on("-o level,price", "--order=level,price", "") { |x| orderStr = x }
        parser.on("-h", "--help", "Отображает это сообщение") { puts parser }
    end
rescue        
end

fields = fieldStr.split(",")
orders = orderStr.split(",")

params = HTTP::Params.build do |query|
    if !fieldStr.empty?
        query.add "fields", fieldStr
    end

    if !orderStr.empty?        
        query.add "orders", orderStr
    end
end

res = Crest.get(
  "http://localhost:8090/bonds?#{params}"
)

response = JSON.parse(res.body)
bondArr = response["bonds"].as_a
bondArr.each do |bond|
    s = ""
    fields.each do |field|
        v = bond[field].to_s        
        s += "#{field}: #{v} "
    end
    
    puts s
end