require "http"
require "crest"
require "json"
require "option_parser"

enum OptionState 
    # Перечисление полей облигации
    FieldList
    # Запрашивает облигации
    Fetch
    # Отображает помощь
    Help
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

state = OptionState::Help
fieldStr = "name,isin,price"
filterStr = ""
orderStr = ""
helpStr = ""

begin
    OptionParser.parse do |parser|
        parser.banner = "Использование: obligator_console [аргументы]"
        parser.on("-l", "--list", "Возвращает список доступных полей") { |x| 
            state = OptionState::FieldList
        }

        parser.on("-b fullname,isin,price", "--bond=name,isin,price", "Указывает по каким полям нужно вернуть информацию") { |x| 
            state = OptionState::Fetch
            fieldStr = x
        }
        parser.on("-f listingLevel[=]1,price[<=]100", "--filter=listLevel[=]1,price[<=]100", "Фильтрует по полям облигации") { |x| 
            filterStr = x
        }
        parser.on("-o level|d,price", "--order=level|d,price", "Сортирует по полям облигации. a - по возрастанию, d - по убыванию. Если не указан тип сортировки то применяется по возрастанию") { |x| 
            orderStr = x
        }
        parser.on("-h", "--help", "Отображает это сообщение") {
            state == OptionState::Help
            helpStr = parser.to_s
        }        
    end
rescue
end

case state
when OptionState::FieldList
    execBondFields()
when OptionState::Fetch
    execBondFetch(fieldStr, filterStr, orderStr)
when OptionState::Help
    puts helpStr
else
end