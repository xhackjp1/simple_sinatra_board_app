class User < Modelbase
  class << self
    def attributes
      ["id", "name", "address"]
    end
  end
end