# Информация хранилища об облигации
class StoreBondInfo
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

    # Считает реальную стоимость в процентах
    # Для расчёта требуется текущая банковская ставка
    def calcRealPrice(bankPercent : Float64) : Float64
        totalC = 0.0
        calcC = (couponPercent * initialFaceValue) / 100
        couponFrequency.times do |x|
            i = x + 1                
            totalC += calcC / ((1 + bankPercent / 100.0) ** i)
        end

        h = initialFaceValue / ((1 + bankPercent / 100.0) ** couponFrequency)
        res = totalC + h
        return res / 10.0
    end    
end