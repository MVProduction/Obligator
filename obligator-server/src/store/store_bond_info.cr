# Словарь со значениями облигации
alias BondHash = Hash(String, BondValue)

# Возможные значения полей облигации
alias BondValue = Int32 | Int64 | Float64 | String | Time | Nil

# Информация о поле облигации
class StoreBondFieldInfo
    # Имя поля
    getter name : String

    # Описание поля
    getter description : String

    # Функция возвращающая значение
    getter func : Proc(StoreBondInfo, BondValue)

    # Конструктор
    def initialize(@name, @description, @func)        
    end
end

# Информация хранилища об облигации
class StoreBondInfo
    # Поля с функциями получения значений полей по имени
    @@fields : Hash(String, StoreBondFieldInfo) = {
        "fullname" => StoreBondFieldInfo.new("fullname","Полное название", ->(b : StoreBondInfo) { b.fullname.as(BondValue) }),
        "isin" => StoreBondFieldInfo.new("isin","Идентификатор isin", ->(b : StoreBondInfo) { b.isin.as(BondValue) }),
        "faceValue" => StoreBondFieldInfo.new("faceValue","Текущий номинал", ->(b : StoreBondInfo) { b.faceValue.as(BondValue) }),
        "initialFaceValue" => StoreBondFieldInfo.new("initialFaceValue","Начальный номинал", ->(b : StoreBondInfo) { b.initialFaceValue.as(BondValue) }),
        "currency" => StoreBondFieldInfo.new("currency","Тип валюты", ->(b : StoreBondInfo) { b.currency.as(BondValue) }),
        "listLevel" => StoreBondFieldInfo.new("listLevel","Уровень листинга", ->(b : StoreBondInfo) { b.listLevel.as(BondValue) }),
        "issueSize" => StoreBondFieldInfo.new("issueSize","Размер выпуска", ->(b : StoreBondInfo) { b.issueSize.as(BondValue) }),
        "issueDate" => StoreBondFieldInfo.new("issueDate","Дата выпуска", ->(b : StoreBondInfo) { b.issueDate.as(BondValue) }),
        "endDate" => StoreBondFieldInfo.new("endDate","Дата погашения", ->(b : StoreBondInfo) { b.endDate.as(BondValue) }),
        "couponFrequency" => StoreBondFieldInfo.new("couponFrequency","Частота выплаты купона в год", ->(b : StoreBondInfo) { b.couponFrequency.as(BondValue) }),
        "couponDate" => StoreBondFieldInfo.new("couponDate","Дата выплаты купона", ->(b : StoreBondInfo) { b.couponDate.as(BondValue) }),
        "couponPercent" => StoreBondFieldInfo.new("couponPercent","Процент купона", ->(b : StoreBondInfo) { b.couponPercent.as(BondValue) }),
        "offerDate" => StoreBondFieldInfo.new("offerDate","Дата оферты", ->(b : StoreBondInfo) { b.offerDate.as(BondValue) }),
        "price" => StoreBondFieldInfo.new("price","Цена в процентах", ->(b : StoreBondInfo) { b.price.as(BondValue) }),
    }

    # Полное название
    getter fullname : String
    # Идентификатор
    getter isin : String
    # Текущий номинал
    getter faceValue : Float64
    # Начальный номинал
    getter initialFaceValue : Float64
    # Тип валюты
    getter currency : String
    # Уровень листинга
    getter listLevel : Int32
    # Размер выпуска
    getter issueSize : Int64
    # Дата выпуска
    getter issueDate : Time
    # Дата погашения
    getter endDate : Time
    # Частота выплаты купона в год
    getter couponFrequency : Int32
    # Дата выплаты купона
    getter couponDate : Time
    # Процент купона. Может и не быть
    getter couponPercent : Float64
    # Дата оферты
    getter offerDate : Time?
    # Цена в процентах
    getter price : Float64

    # Возвращает возможные имена полей
    def self.getFieldNames() : Array(StoreBondFieldInfo)
        @@fields.values
    end

    # Конструктор
    def initialize(
        @fullname, 
        @isin, 
        @faceValue, 
        @initialFaceValue, 
        @currency, 
        @listLevel, 
        @issueSize, 
        @issueDate, 
        @endDate, 
        @couponFrequency, 
        @couponDate, 
        @couponPercent, 
        @offerDate,
        @price)
    end    

    # Возвращает облигацию в виде словаря
    def getBondAsHash(fields : Array(String)) : BondHash
        res = BondHash.new

        fields.each do |x|
            res[x] = getValueByName(x)
        end

        return res
    end

    # Возвращает 
    def getValueByName(name : String) : BondValue
        info = @@fields[name]?
        return info.try &.func.call(self)
    end   
end