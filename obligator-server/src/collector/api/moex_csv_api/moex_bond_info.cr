# Информация об облигации с биржи moex
class MoexBondInfo
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

    def initialize(@fullname, @isin, @faceValue, @initialFaceValue, @currency, @listLevel, @issueSize, @issueDate, @endDate, @couponFrequency, @couponDate, @couponPercent, @offerDate)        
    end

    # Переводит в строку
    def to_s(io : IO)
        issueDateStr = issueDate.to_s("%d.%m.%Y")
        endDateStr = endDate.to_s("%d.%m.%Y")
        couponDateStr = couponDate.to_s("%d.%m.%Y")
        offerDateStr = offerDate ? offerDate.not_nil!.to_s("%d.%m.%Y") : ""
        io.puts "isin: #{isin} fullname: #{fullname} faceValue: #{faceValue} initialFaceValue: #{initialFaceValue} currency: #{currency} listLevel: #{listLevel} issueSize: #{issueSize} issueDate: #{issueDateStr} endDate: #{endDateStr} couponFrequency: #{couponFrequency} couponDate: #{couponDateStr} couponPercent: #{couponPercent} offerDate: #{offerDate}"
    end
end