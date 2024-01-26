class SetDefaultStatusInShopRegisterRequests < ActiveRecord::Migration[7.0]
  def change
    change_column_default :shop_register_requests, :status, from: nil, to: 0
  end
end
