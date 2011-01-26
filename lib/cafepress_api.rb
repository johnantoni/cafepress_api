require 'rexml/document'
require 'open-uri'
module CafePressAPI
  RESULTS_PER_PAGE = 100

  def self.user_token(app_key = ENV['cp_app_key'], email = ENV['cp_email'], password = ENV['cp_password'])
    content = ''
    open("http://open-api.cafepress.com/authentication.getUserToken.cp?appKey=#{app_key}&email=#{email}&password=#{password}") do |s| content = s.read end
    REXML::Document.new(content).root.text
  end

  def self.get_store_products(cafepress_store_id, app_key = ENV['cp_app_key'])
    content = ''
    products = []
    open("http://open-api.cafepress.com/product.listByStore.cp?v=3&appKey=#{app_key}&storeId=#{cafepress_store_id}&page=0&pageSize=#{RESULTS_PER_PAGE}") do |s| content = s.read end
    doc = REXML::Document.new(content)
    doc.root.elements.to_a.each do |product|
      begin
        cafepress_back_design_id = product.get_elements("mediaConfiguration[@perspectives='Back']").first.attributes['designId']
      rescue
        cafepress_back_design_id = nil
      end

      products << {
        :name => product.attributes['name'],
        :default_caption => product.attributes['defaultCaption'],
        :cafepress_product_id => product.attributes['id'],
        :url => product.attributes['marketplaceUri'],
        :cafepress_design_id => product.get_elements("mediaConfiguration[@perspectives='Front']").first.attributes['designId'],
        :cafepress_back_design_id => cafepress_back_design_id
      }
    end
    products
  end

  def self.get_design_url(cafepress_design_id, app_key = ENV['cp_app_key'])
    content = ''
    open("http://open-api.cafepress.com/design.find.cp?v=3&appKey=#{app_key}&id=#{cafepress_design_id}") do |s| content = s.read end
    doc = REXML::Document.new(content)
    doc.root.attributes['mediaUrl']
  end

  def self.get_store(cafepress_store_id, app_key = ENV['cp_app_key'])
    content = ''
    open("http://open-api.cafepress.com/store.findByStoreId.cp?v=3&appKey=#{app_key}&storeId=#{cafepress_store_id}") do |s| content = s.read end
    doc = REXML::Document.new(content)

    {:store_id => cafepress_store_id, :description => doc.root.attributes['description']}
  end
end
