class CreateTeamfunds < ActiveRecord::Migration
  def change
    create_table :teamfunds do |t|
      t.string :campaign_id
      t.string :user_email
      t.integer :amount

      t.timestamps
    end
  end
end
