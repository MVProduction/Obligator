require "http"
require "crest"
require "json"
require "option_parser"

enum OptionState 
    # Перечисление полей облигации
    FieldList
    # Запрашивает облигации
    Fetch
end

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
def execBondFetch(fieldStr : String, filterStr : String, orderStr : String)  
    params = HTTP::Params.build do |query|
        if !fieldStr.empty?
            query.add "fields", fieldStr
        end

        if !filterStr.empty?
            query.add "filter", filterStr
        end

        if !orderStr.empty?        
            query.add "orders", orderStr
        end
    end
    p params

    res = Crest.get(
        "http://localhost:8090/bonds/fetch?#{params}"
    )

    fieldDescr = getBondFields()

    fields = fieldStr.split(",")

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

state = OptionState::Fetch
fieldStr = "name,isin,price"
filterStr = ""
orderStr = ""

begin
    OptionParser.parse do |parser|
        parser.banner = "Использование: obligator_console [аргументы]"
        parser.on("-l", "--list", "Возвращает список доступных полей") { |x| state = OptionState::FieldList }
        parser.on("-b name,isin,price", "--bond=name,isin,price", "Указывает по каким полям нужно вернуть информацию") { |x| fieldStr = x }
        parser.on("-f listingLevel=1,price<100", "--filter=listLevel=1,price<100", "Фильтрует по полям облигации") { |x| filterStr = x }
        parser.on("-o level,price", "--order=level,price", "") { |x| orderStr = x }
        parser.on("-h", "--help", "Отображает это сообщение") { puts parser }
    end
rescue        
end

case state
when OptionState::FieldList
    execBondFields()
when OptionState::Fetch
    execBondFetch(fieldStr, filterStr, orderStr)
else

end