
class CreateSearchLinks < ActiveRecord::Migration
  def self.up
    create_table :search_links do |t|
      t.string  :promotionType
      t.string  :linkDestination
      t.string  :category
      t.string  :language
      t.string  :advertiserName
      t.string  :linkDescription
      t.string  :saleCommission
      t.string  :linkType
      t.string  :linkName
      t.decimal :clickCommission
      t.integer :advertiserId
      t.integer :linkId
    end
  end
end


CreateSearchLinks.migrate(:up)

# class CreateCategories < ActiveRecord::Migration
#   def self.up
#     create_table :categories do
#       t.string :name
#     end
#   end
# end
