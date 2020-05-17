require "json"

# Менеджер настроек
class SettingsManager
    @@instance = SettingsManager.new

    @settings : JSON::Any

    def self.instance
        @@instance
    end

    def initialize
        @settings = File.open("settings.json") do |file|
            JSON.parse(file)
        end
    end

    # Возвращает значение
    def get(key : String) : String        
        @settings[key].as_s
    end
end