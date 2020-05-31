require "kemal"

require "json"
require "invest_api"

require "./settings/settings_manager"
require "./store/bond_store"

# https://tinkoffcreditsystems.github.io/invest-openapi/swagger-ui/#/market/get_market_bonds

DEFAULT_FIELDS = "name,isin,price"

# Возможные значения полей облигации
alias BondValue = Int32 | Int64 | Float64 | String | Time | Nil

alias BondHash = Hash(String, BondValue)


# Группа облигаций 
class BondGroup
    # Ключ
    getter key : BondValue  

    # Список облигаций
    getter bonds : Array(StoreBondInfo)
    
    # Конструктор
    def initialize(@key, @bonds)    
    end
end

# Возвращает облигацию в виде словаря
def getBondAsHash(bond : StoreBondInfo, fields : Array(String)) : BondHash
    res = BondHash.new

    fields.each do |x|
        res[x] = getBondValueByName(bond, x)
    end

    return res
end

# Сортирует массив с группами облигаций по ключу
def sortBondGroupByKey(bonds : Array(BondGroup)) : Array(BondGroup)    
    sbonds = bonds.sort! { |a,b|     
      if a.key.is_a?(String) && b.key.is_a?(String)      
        next a.key.to_s <=> b.key.to_s
      elsif a.key.is_a?(Int32) && b.key.is_a?(Int32)      
        next a.key.as(Int32) <=> b.key.as(Int32)
      elsif a.key.is_a?(Int64) && b.key.is_a?(Int64)      
        next a.key.as(Int64) <=> b.key.as(Int64)  
      elsif a.key.is_a?(Float64) && b.key.is_a?(Float64)      
        next a.key.as(Float64) <=> b.key.as(Float64)
      end
      next 0
    }
    
    return sbonds
end

# Сортирует облигации
def sortBondsByOrders(bonds : Array(StoreBondInfo), orders : Array(String)) : Array(StoreBondInfo)      
    order = orders.shift
    groups = bonds.group_by { |x| getBondValueByName(x, order) }
       
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
  
    bondGroups = sortBondGroupByKey(bondGroups)  
  
    res = Array(StoreBondInfo).new
    bondGroups.each do |x|    
      res.concat(x.bonds)    
    end
  
    return res
  end

# Возвращает значение облигации по имени
def getBondValueByName(bond : StoreBondInfo, name : String) : BondValue
    case name    
    when "name"
        return bond.fullname
    when "isin"
        return bond.isin
    when "price"
        return bond.price
    when "face"
        return bond.faceValue        
    when "initFace"
        return bond.initialFaceValue
    when "currency"
        return bond.currency
    when "level"
        return bond.listLevel
    when "size"
        return bond.issueSize
    when "issueDate"
        return bond.issueDate
    when "endDate"
        return bond.endDate
    when "frequency"
        return bond.couponFrequency
    when "couponDate"
        return bond.couponDate
    when "couponPercent"
        return bond.couponPercent
    when "offerDate"
        return bond.offerDate
    else
    end
end


# Возвращает список облигаций
get "/bonds" do |env|
    env.response.content_type = "application/json"
    # Возвращаемые поля
    fieldStr = env.params.query["fields"]? || DEFAULT_FIELDS
    orderStr = env.params.query["orders"]?
    fields = fieldStr.split(",")

    allBonds = BondStore.instance.getBonds()

    if orderStr
        orderFields = orderStr.split(",")
        allBonds = sortBondsByOrders(allBonds, orderFields)
    end

    res = Array(BondHash).new
    allBonds.each do |bond|
        bondData = getBondAsHash(bond, fields)

        if fields.any?("realPrice")
            # Брать ставку из интернета
            realPrice = bond.calcRealPrice(5.5).round(2)
            bondData["realPrice"] = realPrice
        end

        res << bondData
    end

    next {
        bonds: res
    }.to_json
end
  
Kemal.run 8090