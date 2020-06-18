require "kemal"

require "json"
require "invest_api"

require "./settings/settings_manager"
require "./store/bond_store"
require "./analytics/bond_calculator"

# https://tinkoffcreditsystems.github.io/invest-openapi/swagger-ui/#/market/get_market_bonds

DEFAULT_FIELDS = "fullname,isin,price"

# Группа облигаций 
class BondGroup
    # Ключ
    getter key : BondValue  

    # Список облигаций
    getter bonds : Array(BondHash)
    
    # Конструктор
    def initialize(@key, @bonds)    
    end
end

# Сортирует массив с группами облигаций по ключу
def sortBondGroupByKey(bonds : Array(BondGroup), orderType : String?) : Array(BondGroup)
    case orderType
    when "d" # Сортировка по убыванию
        return bonds.sort! { |b, a|            
            if a.key.is_a?(String) && b.key.is_a?(String)      
                next a.key.to_s <=> b.key.to_s
            elsif a.key.is_a?(Int32) && b.key.is_a?(Int32)      
                next a.key.as(Int32) <=> b.key.as(Int32)
            elsif a.key.is_a?(Int64) && b.key.is_a?(Int64)      
                next a.key.as(Int64) <=> b.key.as(Int64)  
            elsif a.key.is_a?(Float64) && b.key.is_a?(Float64)
                next a.key.as(Float64) <=> b.key.as(Float64)
            elsif a.key.is_a?(Time)                
                next a.key.as(Time) <=> b.key.as(Time)
            end
            next 0
        }
    else # Сортировка по возрастанию
        return bonds.sort! { |a,b|     
            if a.key.is_a?(String) && b.key.is_a?(String)      
                next a.key.to_s <=> b.key.to_s
            elsif a.key.is_a?(Int32) && b.key.is_a?(Int32)      
                next a.key.as(Int32) <=> b.key.as(Int32)
            elsif a.key.is_a?(Int64) && b.key.is_a?(Int64)      
                next a.key.as(Int64) <=> b.key.as(Int64)  
            elsif a.key.is_a?(Float64) && b.key.is_a?(Float64)      
                next a.key.as(Float64) <=> b.key.as(Float64)
            elsif a.key.is_a?(Time)
                next a.key.as(Time) <=> b.key.as(Time)            
            end
            next 0
        }
    end        
end

# Сортирует облигации
def sortBondsByOrders(bonds : Array(BondHash), orders : Array(String)) : Array(BondHash)      
    orderData = orders.shift.split("|")
    fieldName = orderData[0]
    orderType = orderData[1]?

    groups = bonds.group_by { |x| x[fieldName] }
       
    bondGroups = Array(BondGroup).new
    groups.each do |k, v| 
      corders = orders.clone
      if orders.empty?
         sb = v
      else
         sb = sortBondsByOrders(v, corders)
      end        
      bg = BondGroup.new(k, sb)
      bondGroups << bg
    end
  
    bondGroups = sortBondGroupByKey(bondGroups, orderType)  
  
    res = Array(BondHash).new
    bondGroups.each do |x|    
      res.concat(x.bonds)    
    end
  
    return res
end

# Применяет оператор фильтра для значений
def applyFilterOperator(operator : String, primeValue, filterValue) : Bool    
    case operator
    when "="
        if primeValue.is_a?(Int32)
            return primeValue == filterValue.as(Int32|Int64|Float64|String).to_i
        elsif primeValue.is_a?(Int64)
            return primeValue == filterValue.as(Int32|Int64|Float64|String).to_i64
        elsif primeValue.is_a?(Float64)
            return primeValue == filterValue.as(Int32|Int64|Float64|String).to_f64
        elsif primeValue.is_a?(String)
            return primeValue == filterValue.to_s
        else
            return primeValue == filterValue
        end
    when ">"
        if primeValue.is_a?(Int32)
            return primeValue > filterValue.as(Int32|Int64|Float64|String).to_i
        elsif primeValue.is_a?(Int64)
            return primeValue > filterValue.as(Int32|Int64|Float64|String).to_i64
        elsif primeValue.is_a?(Float64)
            return primeValue > filterValue.as(Int32|Int64|Float64|String).to_f64        
        end
    when ">="
        if primeValue.is_a?(Int32)
            return primeValue >= filterValue.as(Int32|Int64|Float64|String).to_i
        elsif primeValue.is_a?(Int64)
            return primeValue >= filterValue.as(Int32|Int64|Float64|String).to_i64
        elsif primeValue.is_a?(Float64)
            return primeValue >= filterValue.as(Int32|Int64|Float64|String).to_f64        
        end
    when "<"
        if primeValue.is_a?(Int32)
            return primeValue < filterValue.as(Int32|Int64|Float64|String).to_i
        elsif primeValue.is_a?(Int64)
            return primeValue < filterValue.as(Int32|Int64|Float64|String).to_i64
        elsif primeValue.is_a?(Float64)
            return primeValue < filterValue.as(Int32|Int64|Float64|String).to_f64        
        end
    when "<="
        if primeValue.is_a?(Int32)
            return primeValue <= filterValue.as(Int32|Int64|Float64|String).to_i
        elsif primeValue.is_a?(Int64)
            return primeValue <= filterValue.as(Int32|Int64|Float64|String).to_i64
        elsif primeValue.is_a?(Float64)
            return primeValue <= filterValue.as(Int32|Int64|Float64|String).to_f64        
        end
    else
        return false
    end

    return false
end

# Фильтрует облигации
# Пример фильтра: price<100;listLevel=1
def filterBonds(bonds : Array(BondHash), filterStr : String) : Array(BondHash)
    filterItems = filterStr.split(",")
    filterItems.each do |item|
        p item
        matches = item.match(/([\w]+)\[(.+)\]([\w]+)/).not_nil!
        fieldName = matches[1]
        operator = matches[2]
        v1 = matches[3]

        bonds = bonds.select { |x| 
            v2 = x[fieldName]
            next applyFilterOperator(operator, v2, v1)
        }
    end
    return bonds.select { |x| x != nil }
end

# Сортирует облигации
def orderBonds(bonds : Array(BondHash), orderStr : String) : Array(BondHash)
    if orderStr
        orderFields = orderStr.split(",")
        bonds = sortBondsByOrders(bonds, orderFields)
    end
    return bonds
end

# Данные каждой облигации конвертирует в словарь
def convertBondsToBondHash(bonds : Array(StoreBondInfo), fieldStr : String) : Array(BondHash)
    fields = fieldStr.split(",")

    res = Array(BondHash).new
    bonds.each do |bond|
        bondData = bond.getBondAsHash(fields)

        # Производит нужные расчёты
        if fields.any?("calcPrice")
            # Брать ставку из интернета
            calcPrice = BondCalculator.calcRealPrice(bond.initialFaceValue, bond.couponPercent, bond.couponFrequency,  5.5).round(2)
            bondData["calcPrice"] = calcPrice
        end

        res << bondData
    end

    return res
end

before_all do |env|
    env.response.headers["Access-Control-Allow-Origin"] = "*"
    env.response.headers["Access-Control-Allow-Methods"] = "GET, HEAD, POST, PUT"
    env.response.headers["Access-Control-Allow-Headers"] = "Content-Type, Accept, Origin, Authorization"
    env.response.headers["Access-Control-Max-Age"] = "86400"
end

options "/bonds/fields" do |env|
end

options "/bonds/fetch" do |env|
end

# Возвращает список полей которые можно получить по облигации
get "/bonds/fields" do |env|
    env.response.content_type = "application/json"
    fields = StoreBondInfo.getFieldNames()

    calcFields = [ 
        { "name" => "calcPrice", "description" => "Расчитаная цена в процентах" }        
    ]

    next {
        fields: calcFields.concat(fields.map { |x| { "name" => x.name, "description" => x.description } })
    }.to_json
end

# Возвращает список облигаций
get "/bonds/fetch" do |env|
    env.response.content_type = "application/json"
        
    fieldStr = env.params.query["fields"]? || DEFAULT_FIELDS

    # Получает все облигации
    allBonds = convertBondsToBondHash(BondStore.instance.getBonds(), fieldStr)
    
    # Применяет фильтр
    filterStr = env.params.query["filter"]?
    allBonds = filterBonds(allBonds, filterStr) if filterStr

    # Применяет сортировку
    orderStr = env.params.query["orders"]?    
    allBonds = orderBonds(allBonds, orderStr) if orderStr    
    
    next {
        bonds: allBonds
    }.to_json
end
  
Kemal.run 8090