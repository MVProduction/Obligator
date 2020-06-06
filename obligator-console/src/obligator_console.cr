require "http"
require "crest"
require "json"
require "option_parser"

# Возвращает поля облигации в виде словаря
def getBondFields() : Hash(String, String)
    res = Crest.get(
        "http://localhost:8090/bonds/fields"
    )

    resHash = Hash(String, String).new

    response = JSON.parse(res.body)
    fieldArr = response["fields"].as_a
    fieldArr.each do |f|
        key = f["name"].as_s
        value = f["description"].as_s
        resHash[key] = value
    end

    return resHash
end

# Запрашивает список полей
def execBondFields()
    fields = getBondFields()
    fields.each do |k, v|
        puts "Имя: #{k} Описание: #{v}"
    end
end

# Запрашивает список облигаций
def execBondFetch(fields : Array(String), orders : Array(String))
    fstr = fields.join(",")
    ostr = orders.join(",")
    params = HTTP::Params.build do |query|
        if !fstr.empty?
            query.add "fields", fstr
        end

        if !ostr.empty?        
            query.add "orders", ostr
        end
    end

    res = Crest.get(
        "http://localhost:8090/bonds/fetch?#{params}"
    )

    fieldDescr = getBondFields()

    response = JSON.parse(res.body)
    bondArr = response["bonds"].as_a
    bondArr.each do |bond|
        s = ""
        fields.each do |field|
            v = bond[field].to_s  
            descr = fieldDescr[field]      
            s += "#{descr}: #{v} "
        end
        
        puts s
    end
end

isFieldList = false
fieldStr = "name,isin,price"
orderStr = ""

begin
    OptionParser.parse do |parser|
        parser.banner = "Использование: obligator_console [аргументы]"
        parser.on("-lf", "--field", "Возвращает список доступных полей") { |x| isFieldList = true }
        parser.on("-f name,isin,price", "--field=name,isin,price", "Указывает по каким полям нужно вернуть информацию") { |x| fieldStr = x }
        parser.on("-o level,price", "--order=level,price", "") { |x| orderStr = x }
        parser.on("-h", "--help", "Отображает это сообщение") { puts parser }
    end
rescue        
end

if isFieldList
    execBondFields()
else
    fields = fieldStr.split(",")
    orders = orderStr.split(",")
    execBondFetch(fields, orders)
end