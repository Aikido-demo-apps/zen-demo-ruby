class AddTenantIdtoPets < ActiveRecord::Migration[7.2]
  def change
    add_column :pets, :tenant_id, :string
  end
end
