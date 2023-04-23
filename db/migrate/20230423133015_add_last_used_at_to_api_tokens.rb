class AddLastUsedAtToApiTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :api_tokens, :last_used_at, :datetime
  end
end
