require "crinja"

# Фабрика шаблонов
class TemplateFactory
    # Экземпляр фабрики
    @@instance = TemplateFactory.new

    # Возвращает экземпляр
    def self.instance
        @@instance
    end

    # Конструктор
    def initialize
        @env = Crinja.new
        @env.loader = Crinja::Loader::FileSystemLoader.new("views/")
    end

    # Возвращает шаблон
    def getTemplate(name : String)
        @env.get_template(name)
    end
end