require "csv"

require "./moex_bond_info"

# API для получения информации об инструменте с сайта https://www.moex.com/
class MoexCsvApi
    def self.parseTime(v : String) : Time?
        begin        
            return Time.parse(v, "%d.%m.%Y", Time::Location::UTC)
        rescue
            return nil
        end
    end

    # Возвращает облигации
    def self.getBonds() : Array(MoexBondInfo)
        response = Crest.get(
            "https://iss.moex.com/iss/apps/infogrid/emission/rates.csv?bond_subtype=&index=&iss.dp=comma&iss.df=%25d.%25m.%25Y&iss.tf=%25H:%25M:%25S&iss.dtf=%25d.%25m.%25Y%20%25H:%25M:%25S&iss.only=rates&limit=unlimited&lang=ru"
        )

        res = Array(MoexBondInfo).new

        parser = CSV::Parser.new(response.body, ';')
        i = -1
        headers = Hash(String, Int32).new

        parser.each_row do |row|            
            i += 1

            if i == 2
                row.each_with_index do |v, i|
                    headers[v] = i
                end
            end
            
            next if i < 3
                        
            next if row.size != headers.size
            
            begin
                endDate = parseTime(row[headers["MATDATE"]])                
                next unless endDate

                couponFrequencyStr = row[headers["COUPONFREQUENCY"]]                
                next if couponFrequencyStr.empty?

                couponPercentStr = row[headers["COUPONPERCENT"]].gsub(',', '.')                
                next if couponPercentStr.empty?

                listLevelStr = row[headers["LISTLEVEL"]]                
                next if listLevelStr.empty?

                fullname = row[headers["NAME"]]
                isin = row[headers["ISIN"]]
                faceValue = row[headers["FACEVALUE"]].gsub(',', '.').to_f64
                initialFaceValue = row[headers["INITIALFACEVALUE"]].gsub(',', '.').to_f64
                currency = row[headers["FACEUNIT"]]
                listLevel = listLevelStr.to_i32
                issueSize = row[headers["ISSUESIZE"]].to_i64
                issueDate = parseTime(row[headers["ISSUEDATE"]]).not_nil!                
                couponFrequency = couponFrequencyStr.to_i32
                couponDate = parseTime(row[headers["COUPONDATE"]]).not_nil!
                
                couponPercent = couponPercentStr.to_f64
                offerDate = parseTime(row[headers["OFFERDATE"]])

                res.push(MoexBondInfo.new(
                    fullname: fullname,
                    isin: isin,
                    faceValue: faceValue,
                    initialFaceValue: initialFaceValue,
                    currency: currency,
                    listLevel: listLevel,
                    issueSize: issueSize,
                    issueDate: issueDate,
                    endDate: endDate,
                    couponFrequency: couponFrequency,
                    couponDate: couponDate,
                    couponPercent: couponPercent,
                    offerDate: offerDate
                ))
            rescue e
                puts e.inspect_with_backtrace
            end
        end

        return res
    end
end