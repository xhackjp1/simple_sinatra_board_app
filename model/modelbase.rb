class Modelbase
  require 'active_support/all'

  class << self

    # indexと項目名の対応を保持, 1 => store_id
    # クラスにアクセッサが定義される
    # SpooRecord.index_to_attr にアクセスできる
    attr_accessor :index_to_attr

    def define_attributes()
      @index_to_attr ||= {}

      attributes.each_with_index do |attr, index|
        attr_accessor attr # attrへのアクセッサ
        @index_to_attr[index] = attr # indexと項目名の対応
      end

    end

    def database_name
      self.to_s.downcase.pluralize

    end

    def attributes
      []
    end
  end

  # コンストラクタ
  def initialize(data)
    data.each_with_index do |value, index|
      attr = self.class.index_to_attr[index] # クラスメソッドの `index_to_attr` で読込
      self.send("#{attr}=", value) # 動的ディスパッチ!!
    end
  end

end