require "./store_bond_info"

# Хранилище облигаций
class BondStore
    @@instance = BondStore.new

    # Закэшированные значения
    @allBonds = Array(StoreBondInfo).new

    def self.instance
        @@instance
    end

    def initialize        
    end

    # Возвращает все имеющиеся облигации
    def getBonds() : Array(StoreBondInfo)        
        return @allBonds if !@allBonds.empty?

        token = SettingsManager.instance.get("tinkoff_sandbox_token")
    
        mbonds = MoexCsvApi.getBonds()
        tbonds = TinkoffRestApi.getBonds(token)

        mergedBonds = Array(StoreBondInfo).new
        tbonds.each do |tbond|
            bond = mbonds.find { |mbond| mbond.isin == tbond.isin }
            next if bond.nil?
            nbond = StoreBondInfo.new(
                fullname: bond.fullname,
                isin: bond.isin,
                faceValue: bond.faceValue,
                initialFaceValue: bond.initialFaceValue,
                currency: bond.currency,
                listLevel: bond.listLevel,
                issueSize: bond.issueSize,
                issueDate: bond.issueDate,
                endDate: bond.endDate,
                couponFrequency: bond.couponFrequency,
                couponDate: bond.couponDate,
                couponPercent: bond.couponPercent,
                offerDate: bond.offerDate,
                price: bond.price,
            )
            mergedBonds << nbond
        end

        @allBonds = mergedBonds

        return mergedBonds
    end
end