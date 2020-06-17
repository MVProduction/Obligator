# Считает данные по облигации на лету
module BondCalculator
     # Считает реальную стоимость в процентах
    # Для расчёта требуется текущая банковская ставка
    def self.calcRealPrice(initialFaceValue : Float64, couponPercent : Float64, couponFrequency : Int32, bankPercent : Float64) : Float64
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

    def self.calcNextCouponDate()
    end
end