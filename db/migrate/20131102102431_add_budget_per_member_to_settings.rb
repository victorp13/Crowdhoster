class AddBudgetPerMemberToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :budget_per_member, :string
  end
end
